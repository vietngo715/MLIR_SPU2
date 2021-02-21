//===- RewriterGen.cpp - MLIR pattern rewriter generator ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// RewriterGen uses pattern rewrite definitions to generate rewriter matchers.
//
//===----------------------------------------------------------------------===//

#include "mlir/Support/IndentedOstream.h"
#include "mlir/TableGen/Attribute.h"
#include "mlir/TableGen/Format.h"
#include "mlir/TableGen/GenInfo.h"
#include "mlir/TableGen/Operator.h"
#include "mlir/TableGen/Pattern.h"
#include "mlir/TableGen/Predicate.h"
#include "mlir/TableGen/Type.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FormatAdapters.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/TableGen/Error.h"
#include "llvm/TableGen/Main.h"
#include "llvm/TableGen/Record.h"
#include "llvm/TableGen/TableGenBackend.h"

using namespace mlir;
using namespace mlir::tblgen;

using llvm::formatv;
using llvm::Record;
using llvm::RecordKeeper;

#define DEBUG_TYPE "mlir-tblgen-rewritergen"

namespace llvm {
template <>
struct format_provider<mlir::tblgen::Pattern::IdentifierLine> {
  static void format(const mlir::tblgen::Pattern::IdentifierLine &v,
                     raw_ostream &os, StringRef style) {
    os << v.first << ":" << v.second;
  }
};
} // end namespace llvm

//===----------------------------------------------------------------------===//
// PatternEmitter
//===----------------------------------------------------------------------===//

namespace {
class PatternEmitter {
public:
  PatternEmitter(Record *pat, RecordOperatorMap *mapper, raw_ostream &os);

  // Emits the mlir::RewritePattern struct named `rewriteName`.
  void emit(StringRef rewriteName);

private:
  // Emits the code for matching ops.
  void emitMatchLogic(DagNode tree, StringRef opName);

  // Emits the code for rewriting ops.
  void emitRewriteLogic();

  //===--------------------------------------------------------------------===//
  // Match utilities
  //===--------------------------------------------------------------------===//

  // Emits C++ statements for matching the DAG structure.
  void emitMatch(DagNode tree, StringRef name, int depth);

  // Emits C++ statements for matching using a native code call.
  void emitNativeCodeMatch(DagNode tree, StringRef name, int depth);

  // Emits C++ statements for matching the op constrained by the given DAG
  // `tree` returning the op's variable name.
  void emitOpMatch(DagNode tree, StringRef opName, int depth);

  // Emits C++ statements for matching the `argIndex`-th argument of the given
  // DAG `tree` as an operand. operandIndex is the index in the DAG excluding
  // the preceding attributes.
  void emitOperandMatch(DagNode tree, StringRef opName, int argIndex,
                        int operandIndex, int depth);

  // Emits C++ statements for matching the `argIndex`-th argument of the given
  // DAG `tree` as an attribute.
  void emitAttributeMatch(DagNode tree, StringRef opName, int argIndex,
                          int depth);

  // Emits C++ for checking a match with a corresponding match failure
  // diagnostic.
  void emitMatchCheck(StringRef opName, const FmtObjectBase &matchFmt,
                      const llvm::formatv_object_base &failureFmt);

  // Emits C++ for checking a match with a corresponding match failure
  // diagnostics.
  void emitMatchCheck(StringRef opName, const std::string &matchStr,
                      const std::string &failureStr);

  //===--------------------------------------------------------------------===//
  // Rewrite utilities
  //===--------------------------------------------------------------------===//

  // The entry point for handling a result pattern rooted at `resultTree`. This
  // method dispatches to concrete handlers according to `resultTree`'s kind and
  // returns a symbol representing the whole value pack. Callers are expected to
  // further resolve the symbol according to the specific use case.
  //
  // `depth` is the nesting level of `resultTree`; 0 means top-level result
  // pattern. For top-level result pattern, `resultIndex` indicates which result
  // of the matched root op this pattern is intended to replace, which can be
  // used to deduce the result type of the op generated from this result
  // pattern.
  std::string handleResultPattern(DagNode resultTree, int resultIndex,
                                  int depth);

  // Emits the C++ statement to replace the matched DAG with a value built via
  // calling native C++ code.
  std::string handleReplaceWithNativeCodeCall(DagNode resultTree, int depth);

  // Returns the symbol of the old value serving as the replacement.
  StringRef handleReplaceWithValue(DagNode tree);

  // Returns the location value to use.
  std::pair<bool, std::string> getLocation(DagNode tree);

  // Returns the location value to use.
  std::string handleLocationDirective(DagNode tree);

  // Emits the C++ statement to build a new op out of the given DAG `tree` and
  // returns the variable name that this op is assigned to. If the root op in
  // DAG `tree` has a specified name, the created op will be assigned to a
  // variable of the given name. Otherwise, a unique name will be used as the
  // result value name.
  std::string handleOpCreation(DagNode tree, int resultIndex, int depth);

  using ChildNodeIndexNameMap = DenseMap<unsigned, std::string>;

  // Emits a local variable for each value and attribute to be used for creating
  // an op.
  void createSeparateLocalVarsForOpArgs(DagNode node,
                                        ChildNodeIndexNameMap &childNodeNames);

  // Emits the concrete arguments used to call an op's builder.
  void supplyValuesForOpArgs(DagNode node,
                             const ChildNodeIndexNameMap &childNodeNames,
                             int depth);

  // Emits the local variables for holding all values as a whole and all named
  // attributes as a whole to be used for creating an op.
  void createAggregateLocalVarsForOpArgs(
      DagNode node, const ChildNodeIndexNameMap &childNodeNames, int depth);

  // Returns the C++ expression to construct a constant attribute of the given
  // `value` for the given attribute kind `attr`.
  std::string handleConstantAttr(Attribute attr, StringRef value);

  // Returns the C++ expression to build an argument from the given DAG `leaf`.
  // `patArgName` is used to bound the argument to the source pattern.
  std::string handleOpArgument(DagLeaf leaf, StringRef patArgName);

  //===--------------------------------------------------------------------===//
  // General utilities
  //===--------------------------------------------------------------------===//

  // Collects all of the operations within the given dag tree.
  void collectOps(DagNode tree, llvm::SmallPtrSetImpl<const Operator *> &ops);

  // Returns a unique symbol for a local variable of the given `op`.
  std::string getUniqueSymbol(const Operator *op);

  //===--------------------------------------------------------------------===//
  // Symbol utilities
  //===--------------------------------------------------------------------===//

  // Returns how many static values the given DAG `node` correspond to.
  int getNodeValueCount(DagNode node);

private:
  // Pattern instantiation location followed by the location of multiclass
  // prototypes used. This is intended to be used as a whole to
  // PrintFatalError() on errors.
  ArrayRef<llvm::SMLoc> loc;

  // Op's TableGen Record to wrapper object.
  RecordOperatorMap *opMap;

  // Handy wrapper for pattern being emitted.
  Pattern pattern;

  // Map for all bound symbols' info.
  SymbolInfoMap symbolInfoMap;

  // The next unused ID for newly created values.
  unsigned nextValueId;

  raw_indented_ostream os;

  // Format contexts containing placeholder substitutions.
  FmtContext fmtCtx;

  // Number of op processed.
  int opCounter = 0;
};
} // end anonymous namespace

PatternEmitter::PatternEmitter(Record *pat, RecordOperatorMap *mapper,
                               raw_ostream &os)
    : loc(pat->getLoc()), opMap(mapper), pattern(pat, mapper),
      symbolInfoMap(pat->getLoc()), nextValueId(0), os(os) {
  fmtCtx.withBuilder("rewriter");
}

std::string PatternEmitter::handleConstantAttr(Attribute attr,
                                               StringRef value) {
  if (!attr.isConstBuildable())
    PrintFatalError(loc, "Attribute " + attr.getAttrDefName() +
                             " does not have the 'constBuilderCall' field");

  // TODO: Verify the constants here
  return std::string(tgfmt(attr.getConstBuilderTemplate(), &fmtCtx, value));
}

// Helper function to match patterns.
void PatternEmitter::emitMatch(DagNode tree, StringRef name, int depth) {
  if (tree.isNativeCodeCall()) {
    emitNativeCodeMatch(tree, name, depth);
    return;
  }

  if (tree.isOperation()) {
    emitOpMatch(tree, name, depth);
    return;
  }

  PrintFatalError(loc, "encountered non-op, non-NativeCodeCall match.");
}

// Helper function to match patterns.
void PatternEmitter::emitNativeCodeMatch(DagNode tree, StringRef opName,
                                         int depth) {
  LLVM_DEBUG(llvm::dbgs() << "handle NativeCodeCall matcher pattern: ");
  LLVM_DEBUG(tree.print(llvm::dbgs()));
  LLVM_DEBUG(llvm::dbgs() << '\n');

  // TODO(suderman): iterate through arguments, determine their types, output
  // names.
  SmallVector<std::string, 8> capture(8);
  if (tree.getNumArgs() > 8) {
    PrintFatalError(loc,
                    "unsupported NativeCodeCall matcher argument numbers: " +
                        Twine(tree.getNumArgs()));
  }

  raw_indented_ostream::DelimitedScope scope(os);

  os << "if(!" << opName << ") return ::mlir::failure();\n";
  for (int i = 0, e = tree.getNumArgs(); i != e; ++i) {
    std::string argName = formatv("arg{0}_{1}", depth, i);
    if (DagNode argTree = tree.getArgAsNestedDag(i)) {
      os << "Value " << argName << ";\n";
    } else {
      auto leaf = tree.getArgAsLeaf(i);
      if (leaf.isAttrMatcher() || leaf.isConstantAttr()) {
        os << "Attribute " << argName << ";\n";
      } else if (leaf.isOperandMatcher()) {
        os << "Operation " << argName << ";\n";
      }
    }

    capture[i] = std::move(argName);
  }

  bool hasLocationDirective;
  std::string locToUse;
  std::tie(hasLocationDirective, locToUse) = getLocation(tree);

  auto fmt = tree.getNativeCodeTemplate();
  auto nativeCodeCall = std::string(tgfmt(
      fmt, &fmtCtx.addSubst("_loc", locToUse), opName, capture[0], capture[1],
      capture[2], capture[3], capture[4], capture[5], capture[6], capture[7]));

  os << "if (failed(" << nativeCodeCall << ")) return ::mlir::failure();\n";

  for (int i = 0, e = tree.getNumArgs(); i != e; ++i) {
    auto name = tree.getArgName(i);
    if (!name.empty() && name != "_") {
      os << formatv("{0} = {1};\n", name, capture[i]);
    }
  }

  for (int i = 0, e = tree.getNumArgs(); i != e; ++i) {
    std::string argName = capture[i];

    // Handle nested DAG construct first
    if (DagNode argTree = tree.getArgAsNestedDag(i)) {
      PrintFatalError(
          loc, formatv("Matching nested tree in NativeCodecall not support for "
                       "{0} as arg {1}",
                       argName, i));
    }

    DagLeaf leaf = tree.getArgAsLeaf(i);
    auto constraint = leaf.getAsConstraint();

    auto self = formatv("{0}", argName);
    emitMatchCheck(
        opName,
        tgfmt(constraint.getConditionTemplate(), &fmtCtx.withSelf(self)),
        formatv("\"operand {0} of native code call '{1}' failed to satisfy "
                "constraint: "
                "'{2}'\"",
                i, tree.getNativeCodeTemplate(), constraint.getSummary()));
  }

  LLVM_DEBUG(llvm::dbgs() << "done emitting match for native code call\n");
}

// Helper function to match patterns.
void PatternEmitter::emitOpMatch(DagNode tree, StringRef opName, int depth) {
  Operator &op = tree.getDialectOp(opMap);
  LLVM_DEBUG(llvm::dbgs() << "start emitting match for op '"
                          << op.getOperationName() << "' at depth " << depth
                          << '\n');

  std::string castedName = formatv("castedOp{0}", depth);
  os << formatv("auto {0} = ::llvm::dyn_cast_or_null<{2}>({1}); "
                "(void){0};\n",
                castedName, opName, op.getQualCppClassName());
  // Skip the operand matching at depth 0 as the pattern rewriter already does.
  if (depth != 0) {
    // Skip if there is no defining operation (e.g., arguments to function).
    os << formatv("if (!{0}) return ::mlir::failure();\n", castedName);
  }
  if (tree.getNumArgs() != op.getNumArgs()) {
    PrintFatalError(loc, formatv("op '{0}' argument number mismatch: {1} in "
                                 "pattern vs. {2} in definition",
                                 op.getOperationName(), tree.getNumArgs(),
                                 op.getNumArgs()));
  }

  // If the operand's name is set, set to that variable.
  auto name = tree.getSymbol();
  if (!name.empty())
    os << formatv("{0} = {1};\n", name, castedName);

  for (int i = 0, e = tree.getNumArgs(), nextOperand = 0; i != e; ++i) {
    auto opArg = op.getArg(i);
    std::string argName = formatv("op{0}", depth + 1);

    // Handle nested DAG construct first
    if (DagNode argTree = tree.getArgAsNestedDag(i)) {
      if (auto *operand = opArg.dyn_cast<NamedTypeConstraint *>()) {
        if (operand->isVariableLength()) {
          auto error = formatv("use nested DAG construct to match op {0}'s "
                               "variadic operand #{1} unsupported now",
                               op.getOperationName(), i);
          PrintFatalError(loc, error);
        }
      }
      os << "{\n";

      // Attributes don't count for getODSOperands.
      os.indent() << formatv(
          "auto *{0} = "
          "(*{1}.getODSOperands({2}).begin()).getDefiningOp();\n",
          argName, castedName, nextOperand++);
      emitMatch(argTree, argName, depth + 1);
      os << formatv("tblgen_ops[{0}] = {1};\n", ++opCounter, argName);
      os.unindent() << "}\n";
      continue;
    }

    // Next handle DAG leaf: operand or attribute
    if (opArg.is<NamedTypeConstraint *>()) {
      // emitOperandMatch's argument indexing counts attributes.
      emitOperandMatch(tree, castedName, i, nextOperand, depth);
      ++nextOperand;
    } else if (opArg.is<NamedAttribute *>()) {
      emitAttributeMatch(tree, opName, i, depth);
    } else {
      PrintFatalError(loc, "unhandled case when matching op");
    }
  }
  LLVM_DEBUG(llvm::dbgs() << "done emitting match for op '"
                          << op.getOperationName() << "' at depth " << depth
                          << '\n');
}

void PatternEmitter::emitOperandMatch(DagNode tree, StringRef opName,
                                      int argIndex, int operandIndex,
                                      int depth) {
  Operator &op = tree.getDialectOp(opMap);
  auto *operand = op.getArg(argIndex).get<NamedTypeConstraint *>();
  auto matcher = tree.getArgAsLeaf(argIndex);

  // If a constraint is specified, we need to generate C++ statements to
  // check the constraint.
  if (!matcher.isUnspecified()) {
    if (!matcher.isOperandMatcher()) {
      PrintFatalError(
          loc, formatv("the {1}-th argument of op '{0}' should be an operand",
                       op.getOperationName(), argIndex + 1));
    }

    // Only need to verify if the matcher's type is different from the one
    // of op definition.
    Constraint constraint = matcher.getAsConstraint();
    if (operand->constraint != constraint) {
      if (operand->isVariableLength()) {
        auto error = formatv(
            "further constrain op {0}'s variadic operand #{1} unsupported now",
            op.getOperationName(), argIndex);
        PrintFatalError(loc, error);
      }
      auto self = formatv("(*{0}.getODSOperands({1}).begin()).getType()",
                          opName, operandIndex);
      emitMatchCheck(
          opName,
          tgfmt(constraint.getConditionTemplate(), &fmtCtx.withSelf(self)),
          formatv("\"operand {0} of op '{1}' failed to satisfy constraint: "
                  "'{2}'\"",
                  operand - op.operand_begin(), op.getOperationName(),
                  constraint.getSummary()));
    }
  }

  // Capture the value
  auto name = tree.getArgName(argIndex);
  // `$_` is a special symbol to ignore op argument matching.
  if (!name.empty() && name != "_") {
    // We need to subtract the number of attributes before this operand to get
    // the index in the operand list.
    auto numPrevAttrs = std::count_if(
        op.arg_begin(), op.arg_begin() + argIndex,
        [](const Argument &arg) { return arg.is<NamedAttribute *>(); });

    auto res = symbolInfoMap.findBoundSymbol(name, op, argIndex);
    os << formatv("{0} = {1}.getODSOperands({2});\n",
                  res->second.getVarName(name), opName,
                  argIndex - numPrevAttrs);
  }
}

void PatternEmitter::emitAttributeMatch(DagNode tree, StringRef opName,
                                        int argIndex, int depth) {
  Operator &op = tree.getDialectOp(opMap);
  auto *namedAttr = op.getArg(argIndex).get<NamedAttribute *>();
  const auto &attr = namedAttr->attr;

  os << "{\n";
  os.indent() << formatv("auto tblgen_attr = {0}->getAttrOfType<{1}>(\"{2}\");"
                         "(void)tblgen_attr;\n",
                         opName, attr.getStorageType(), namedAttr->name);

  // TODO: This should use getter method to avoid duplication.
  if (attr.hasDefaultValue()) {
    os << "if (!tblgen_attr) tblgen_attr = "
       << std::string(tgfmt(attr.getConstBuilderTemplate(), &fmtCtx,
                            attr.getDefaultValue()))
       << ";\n";
  } else if (attr.isOptional()) {
    // For a missing attribute that is optional according to definition, we
    // should just capture a mlir::Attribute() to signal the missing state.
    // That is precisely what getAttr() returns on missing attributes.
  } else {
    emitMatchCheck(opName, tgfmt("tblgen_attr", &fmtCtx),
                   formatv("\"expected op '{0}' to have attribute '{1}' "
                           "of type '{2}'\"",
                           op.getOperationName(), namedAttr->name,
                           attr.getStorageType()));
  }

  auto matcher = tree.getArgAsLeaf(argIndex);
  if (!matcher.isUnspecified()) {
    if (!matcher.isAttrMatcher()) {
      PrintFatalError(
          loc, formatv("the {1}-th argument of op '{0}' should be an attribute",
                       op.getOperationName(), argIndex + 1));
    }

    // If a constraint is specified, we need to generate C++ statements to
    // check the constraint.
    emitMatchCheck(
        opName,
        tgfmt(matcher.getConditionTemplate(), &fmtCtx.withSelf("tblgen_attr")),
        formatv("\"op '{0}' attribute '{1}' failed to satisfy constraint: "
                "{2}\"",
                op.getOperationName(), namedAttr->name,
                matcher.getAsConstraint().getSummary()));
  }

  // Capture the value
  auto name = tree.getArgName(argIndex);
  // `$_` is a special symbol to ignore op argument matching.
  if (!name.empty() && name != "_") {
    os << formatv("{0} = tblgen_attr;\n", name);
  }

  os.unindent() << "}\n";
}

void PatternEmitter::emitMatchCheck(
    StringRef opName, const FmtObjectBase &matchFmt,
    const llvm::formatv_object_base &failureFmt) {
  emitMatchCheck(opName, matchFmt.str(), failureFmt.str());
}

void PatternEmitter::emitMatchCheck(StringRef opName,
                                    const std::string &matchStr,
                                    const std::string &failureStr) {

  os << "if (!(" << matchStr << "))";
  os.scope("{\n", "\n}\n").os << "return rewriter.notifyMatchFailure(" << opName
                              << ", [&](::mlir::Diagnostic &diag) {\n  diag << "
                              << failureStr << ";\n});";
}

void PatternEmitter::emitMatchLogic(DagNode tree, StringRef opName) {
  LLVM_DEBUG(llvm::dbgs() << "--- start emitting match logic ---\n");
  int depth = 0;
  emitMatch(tree, opName, depth);

  for (auto &appliedConstraint : pattern.getConstraints()) {
    auto &constraint = appliedConstraint.constraint;
    auto &entities = appliedConstraint.entities;

    auto condition = constraint.getConditionTemplate();
    if (isa<TypeConstraint>(constraint)) {
      auto self = formatv("({0}.getType())",
                          symbolInfoMap.getValueAndRangeUse(entities.front()));
      emitMatchCheck(
          opName, tgfmt(condition, &fmtCtx.withSelf(self.str())),
          formatv("\"value entity '{0}' failed to satisfy constraint: {1}\"",
                  entities.front(), constraint.getSummary()));

    } else if (isa<AttrConstraint>(constraint)) {
      PrintFatalError(
          loc, "cannot use AttrConstraint in Pattern multi-entity constraints");
    } else {
      // TODO: replace formatv arguments with the exact specified
      // args.
      if (entities.size() > 4) {
        PrintFatalError(loc, "only support up to 4-entity constraints now");
      }
      SmallVector<std::string, 4> names;
      int i = 0;
      for (int e = entities.size(); i < e; ++i)
        names.push_back(symbolInfoMap.getValueAndRangeUse(entities[i]));
      std::string self = appliedConstraint.self;
      if (!self.empty())
        self = symbolInfoMap.getValueAndRangeUse(self);
      for (; i < 4; ++i)
        names.push_back("<unused>");
      emitMatchCheck(opName,
                     tgfmt(condition, &fmtCtx.withSelf(self), names[0],
                           names[1], names[2], names[3]),
                     formatv("\"entities '{0}' failed to satisfy constraint: "
                             "{1}\"",
                             llvm::join(entities, ", "),
                             constraint.getSummary()));
    }
  }

  // Some of the operands could be bound to the same symbol name, we need
  // to enforce equality constraint on those.
  // TODO: we should be able to emit equality checks early
  // and short circuit unnecessary work if vars are not equal.
  for (auto symbolInfoIt = symbolInfoMap.begin();
       symbolInfoIt != symbolInfoMap.end();) {
    auto range = symbolInfoMap.getRangeOfEqualElements(symbolInfoIt->first);
    auto startRange = range.first;
    auto endRange = range.second;

    auto firstOperand = symbolInfoIt->second.getVarName(symbolInfoIt->first);
    for (++startRange; startRange != endRange; ++startRange) {
      auto secondOperand = startRange->second.getVarName(symbolInfoIt->first);
      emitMatchCheck(
          opName,
          formatv("*{0}.begin() == *{1}.begin()", firstOperand, secondOperand),
          formatv("\"Operands '{0}' and '{1}' must be equal\"", firstOperand,
                  secondOperand));
    }

    symbolInfoIt = endRange;
  }

  LLVM_DEBUG(llvm::dbgs() << "--- done emitting match logic ---\n");
}

void PatternEmitter::collectOps(DagNode tree,
                                llvm::SmallPtrSetImpl<const Operator *> &ops) {
  // Check if this tree is an operation.
  if (tree.isOperation()) {
    const Operator &op = tree.getDialectOp(opMap);
    LLVM_DEBUG(llvm::dbgs()
               << "found operation " << op.getOperationName() << '\n');
    ops.insert(&op);
  }

  // Recurse the arguments of the tree.
  for (unsigned i = 0, e = tree.getNumArgs(); i != e; ++i)
    if (auto child = tree.getArgAsNestedDag(i))
      collectOps(child, ops);
}

void PatternEmitter::emit(StringRef rewriteName) {
  // Get the DAG tree for the source pattern.
  DagNode sourceTree = pattern.getSourcePattern();

  const Operator &rootOp = pattern.getSourceRootOp();
  auto rootName = rootOp.getOperationName();

  // Collect the set of result operations.
  llvm::SmallPtrSet<const Operator *, 4> resultOps;
  LLVM_DEBUG(llvm::dbgs() << "start collecting ops used in result patterns\n");
  for (unsigned i = 0, e = pattern.getNumResultPatterns(); i != e; ++i) {
    collectOps(pattern.getResultPattern(i), resultOps);
  }
  LLVM_DEBUG(llvm::dbgs() << "done collecting ops used in result patterns\n");

  // Emit RewritePattern for Pattern.
  auto locs = pattern.getLocation();
  os << formatv("/* Generated from:\n    {0:$[ instantiating\n    ]}\n*/\n",
                make_range(locs.rbegin(), locs.rend()));
  os << formatv(R"(struct {0} : public ::mlir::RewritePattern {
  {0}(::mlir::MLIRContext *context)
      : ::mlir::RewritePattern("{1}", {{)",
                rewriteName, rootName);
  // Sort result operators by name.
  llvm::SmallVector<const Operator *, 4> sortedResultOps(resultOps.begin(),
                                                         resultOps.end());
  llvm::sort(sortedResultOps, [&](const Operator *lhs, const Operator *rhs) {
    return lhs->getOperationName() < rhs->getOperationName();
  });
  llvm::interleaveComma(sortedResultOps, os, [&](const Operator *op) {
    os << '"' << op->getOperationName() << '"';
  });
  os << formatv(R"(}, {0}, context) {{})", pattern.getBenefit()) << "\n";

  // Emit matchAndRewrite() function.
  {
    auto classScope = os.scope();
    os.reindent(R"(
    ::mlir::LogicalResult matchAndRewrite(::mlir::Operation *op0,
        ::mlir::PatternRewriter &rewriter) const override {)")
        << '\n';
    {
      auto functionScope = os.scope();

      // Register all symbols bound in the source pattern.
      pattern.collectSourcePatternBoundSymbols(symbolInfoMap);

      LLVM_DEBUG(llvm::dbgs()
                 << "start creating local variables for capturing matches\n");
      os << "// Variables for capturing values and attributes used while "
            "creating ops\n";
      // Create local variables for storing the arguments and results bound
      // to symbols.
      for (const auto &symbolInfoPair : symbolInfoMap) {
        const auto &symbol = symbolInfoPair.first;
        const auto &info = symbolInfoPair.second;

        os << info.getVarDecl(symbol);
      }
      // TODO: capture ops with consistent numbering so that it can be
      // reused for fused loc.
      os << formatv("::mlir::Operation *tblgen_ops[{0}];\n\n",
                    pattern.getSourcePattern().getNumOps());
      LLVM_DEBUG(llvm::dbgs()
                 << "done creating local variables for capturing matches\n");

      os << "// Match\n";
      os << "tblgen_ops[0] = op0;\n";
      emitMatchLogic(sourceTree, "op0");

      os << "\n// Rewrite\n";
      emitRewriteLogic();

      os << "return ::mlir::success();\n";
    }
    os << "};\n";
  }
  os << "};\n\n";
}

void PatternEmitter::emitRewriteLogic() {
  LLVM_DEBUG(llvm::dbgs() << "--- start emitting rewrite logic ---\n");
  const Operator &rootOp = pattern.getSourceRootOp();
  int numExpectedResults = rootOp.getNumResults();
  int numResultPatterns = pattern.getNumResultPatterns();

  // First register all symbols bound to ops generated in result patterns.
  pattern.collectResultPatternBoundSymbols(symbolInfoMap);

  // Only the last N static values generated are used to replace the matched
  // root N-result op. We need to calculate the starting index (of the results
  // of the matched op) each result pattern is to replace.
  SmallVector<int, 4> offsets(numResultPatterns + 1, numExpectedResults);
  // If we don't need to replace any value at all, set the replacement starting
  // index as the number of result patterns so we skip all of them when trying
  // to replace the matched op's results.
  int replStartIndex = numExpectedResults == 0 ? numResultPatterns : -1;
  for (int i = numResultPatterns - 1; i >= 0; --i) {
    auto numValues = getNodeValueCount(pattern.getResultPattern(i));
    offsets[i] = offsets[i + 1] - numValues;
    if (offsets[i] == 0) {
      if (replStartIndex == -1)
        replStartIndex = i;
    } else if (offsets[i] < 0 && offsets[i + 1] > 0) {
      auto error = formatv(
          "cannot use the same multi-result op '{0}' to generate both "
          "auxiliary values and values to be used for replacing the matched op",
          pattern.getResultPattern(i).getSymbol());
      PrintFatalError(loc, error);
    }
  }

  if (offsets.front() > 0) {
    const char error[] = "no enough values generated to replace the matched op";
    PrintFatalError(loc, error);
  }

  os << "auto odsLoc = rewriter.getFusedLoc({";
  for (int i = 0, e = pattern.getSourcePattern().getNumOps(); i != e; ++i) {
    os << (i ? ", " : "") << "tblgen_ops[" << i << "]->getLoc()";
  }
  os << "}); (void)odsLoc;\n";

  // Process auxiliary result patterns.
  for (int i = 0; i < replStartIndex; ++i) {
    DagNode resultTree = pattern.getResultPattern(i);
    auto val = handleResultPattern(resultTree, offsets[i], 0);
    // Normal op creation will be streamed to `os` by the above call; but
    // NativeCodeCall will only be materialized to `os` if it is used. Here
    // we are handling auxiliary patterns so we want the side effect even if
    // NativeCodeCall is not replacing matched root op's results.
    if (resultTree.isNativeCodeCall())
      os << val << ";\n";
  }

  if (numExpectedResults == 0) {
    assert(replStartIndex >= numResultPatterns &&
           "invalid auxiliary vs. replacement pattern division!");
    // No result to replace. Just erase the op.
    os << "rewriter.eraseOp(op0);\n";
  } else {
    // Process replacement result patterns.
    os << "::llvm::SmallVector<::mlir::Value, 4> tblgen_repl_values;\n";
    for (int i = replStartIndex; i < numResultPatterns; ++i) {
      DagNode resultTree = pattern.getResultPattern(i);
      auto val = handleResultPattern(resultTree, offsets[i], 0);
      os << "\n";
      // Resolve each symbol for all range use so that we can loop over them.
      // We need an explicit cast to `SmallVector` to capture the cases where
      // `{0}` resolves to an `Operation::result_range` as well as cases that
      // are not iterable (e.g. vector that gets wrapped in additional braces by
      // RewriterGen).
      // TODO: Revisit the need for materializing a vector.
      os << symbolInfoMap.getAllRangeUse(
          val,
          "for (auto v: ::llvm::SmallVector<::mlir::Value, 4>{ {0} }) {{\n"
          "  tblgen_repl_values.push_back(v);\n}\n",
          "\n");
    }
    os << "\nrewriter.replaceOp(op0, tblgen_repl_values);\n";
  }

  LLVM_DEBUG(llvm::dbgs() << "--- done emitting rewrite logic ---\n");
}

std::string PatternEmitter::getUniqueSymbol(const Operator *op) {
  return std::string(
      formatv("tblgen_{0}_{1}", op->getCppClassName(), nextValueId++));
}

std::string PatternEmitter::handleResultPattern(DagNode resultTree,
                                                int resultIndex, int depth) {
  LLVM_DEBUG(llvm::dbgs() << "handle result pattern: ");
  LLVM_DEBUG(resultTree.print(llvm::dbgs()));
  LLVM_DEBUG(llvm::dbgs() << '\n');

  if (resultTree.isLocationDirective()) {
    PrintFatalError(loc,
                    "location directive can only be used with op creation");
  }

  if (resultTree.isNativeCodeCall()) {
    auto symbol = handleReplaceWithNativeCodeCall(resultTree, depth);
    symbolInfoMap.bindValue(symbol);
    return symbol;
  }

  if (resultTree.isReplaceWithValue())
    return handleReplaceWithValue(resultTree).str();

  // Normal op creation.
  auto symbol = handleOpCreation(resultTree, resultIndex, depth);
  if (resultTree.getSymbol().empty()) {
    // This is an op not explicitly bound to a symbol in the rewrite rule.
    // Register the auto-generated symbol for it.
    symbolInfoMap.bindOpResult(symbol, pattern.getDialectOp(resultTree));
  }
  return symbol;
}

StringRef PatternEmitter::handleReplaceWithValue(DagNode tree) {
  assert(tree.isReplaceWithValue());

  if (tree.getNumArgs() != 1) {
    PrintFatalError(
        loc, "replaceWithValue directive must take exactly one argument");
  }

  if (!tree.getSymbol().empty()) {
    PrintFatalError(loc, "cannot bind symbol to replaceWithValue");
  }

  return tree.getArgName(0);
}

std::string PatternEmitter::handleLocationDirective(DagNode tree) {
  assert(tree.isLocationDirective());
  auto lookUpArgLoc = [this, &tree](int idx) {
    const auto *const lookupFmt = "(*{0}.begin()).getLoc()";
    return symbolInfoMap.getAllRangeUse(tree.getArgName(idx), lookupFmt);
  };

  if (tree.getNumArgs() == 0)
    llvm::PrintFatalError(
        "At least one argument to location directive required");

  if (!tree.getSymbol().empty())
    PrintFatalError(loc, "cannot bind symbol to location");

  if (tree.getNumArgs() == 1) {
    DagLeaf leaf = tree.getArgAsLeaf(0);
    if (leaf.isStringAttr())
      return formatv("::mlir::NameLoc::get(rewriter.getIdentifier(\"{0}\"), "
                     "rewriter.getContext())",
                     leaf.getStringAttr())
          .str();
    return lookUpArgLoc(0);
  }

  std::string ret;
  llvm::raw_string_ostream os(ret);
  std::string strAttr;
  os << "rewriter.getFusedLoc({";
  bool first = true;
  for (int i = 0, e = tree.getNumArgs(); i != e; ++i) {
    DagLeaf leaf = tree.getArgAsLeaf(i);
    // Handle the optional string value.
    if (leaf.isStringAttr()) {
      if (!strAttr.empty())
        llvm::PrintFatalError("Only one string attribute may be specified");
      strAttr = leaf.getStringAttr();
      continue;
    }
    os << (first ? "" : ", ") << lookUpArgLoc(i);
    first = false;
  }
  os << "}";
  if (!strAttr.empty()) {
    os << ", rewriter.getStringAttr(\"" << strAttr << "\")";
  }
  os << ")";
  return os.str();
}

std::string PatternEmitter::handleOpArgument(DagLeaf leaf,
                                             StringRef patArgName) {
  if (leaf.isStringAttr())
    PrintFatalError(loc, "raw string not supported as argument");
  if (leaf.isConstantAttr()) {
    auto constAttr = leaf.getAsConstantAttr();
    return handleConstantAttr(constAttr.getAttribute(),
                              constAttr.getConstantValue());
  }
  if (leaf.isEnumAttrCase()) {
    auto enumCase = leaf.getAsEnumAttrCase();
    if (enumCase.isStrCase())
      return handleConstantAttr(enumCase, enumCase.getSymbol());
    // This is an enum case backed by an IntegerAttr. We need to get its value
    // to build the constant.
    std::string val = std::to_string(enumCase.getValue());
    return handleConstantAttr(enumCase, val);
  }

  LLVM_DEBUG(llvm::dbgs() << "handle argument '" << patArgName << "'\n");
  auto argName = symbolInfoMap.getValueAndRangeUse(patArgName);
  if (leaf.isUnspecified() || leaf.isOperandMatcher()) {
    LLVM_DEBUG(llvm::dbgs() << "replace " << patArgName << " with '" << argName
                            << "' (via symbol ref)\n");
    return argName;
  }
  if (leaf.isNativeCodeCall()) {
    auto repl = tgfmt(leaf.getNativeCodeTemplate(), &fmtCtx.withSelf(argName));
    LLVM_DEBUG(llvm::dbgs() << "replace " << patArgName << " with '" << repl
                            << "' (via NativeCodeCall)\n");
    return std::string(repl);
  }
  PrintFatalError(loc, "unhandled case when rewriting op");
}

std::string PatternEmitter::handleReplaceWithNativeCodeCall(DagNode tree,
                                                            int depth) {
  LLVM_DEBUG(llvm::dbgs() << "handle NativeCodeCall pattern: ");
  LLVM_DEBUG(tree.print(llvm::dbgs()));
  LLVM_DEBUG(llvm::dbgs() << '\n');

  auto fmt = tree.getNativeCodeTemplate();
  // TODO: replace formatv arguments with the exact specified args.
  SmallVector<std::string, 8> attrs(8);
  if (tree.getNumArgs() > 8) {
    PrintFatalError(loc,
                    "unsupported NativeCodeCall replace argument numbers: " +
                        Twine(tree.getNumArgs()));
  }
  bool hasLocationDirective;
  std::string locToUse;
  std::tie(hasLocationDirective, locToUse) = getLocation(tree);

  for (int i = 0, e = tree.getNumArgs() - hasLocationDirective; i != e; ++i) {
    if (tree.isNestedDagArg(i)) {
      attrs[i] = handleResultPattern(tree.getArgAsNestedDag(i), i, depth + 1);
    } else {
      attrs[i] = handleOpArgument(tree.getArgAsLeaf(i), tree.getArgName(i));
    }
    LLVM_DEBUG(llvm::dbgs() << "NativeCodeCall argument #" << i
                            << " replacement: " << attrs[i] << "\n");
  }
  return std::string(tgfmt(fmt, &fmtCtx.addSubst("_loc", locToUse), attrs[0],
                           attrs[1], attrs[2], attrs[3], attrs[4], attrs[5],
                           attrs[6], attrs[7]));
}

int PatternEmitter::getNodeValueCount(DagNode node) {
  if (node.isOperation()) {
    // If the op is bound to a symbol in the rewrite rule, query its result
    // count from the symbol info map.
    auto symbol = node.getSymbol();
    if (!symbol.empty()) {
      return symbolInfoMap.getStaticValueCount(symbol);
    }
    // Otherwise this is an unbound op; we will use all its results.
    return pattern.getDialectOp(node).getNumResults();
  }
  // TODO: This considers all NativeCodeCall as returning one
  // value. Enhance if multi-value ones are needed.
  return 1;
}

std::pair<bool, std::string> PatternEmitter::getLocation(DagNode tree) {
  auto numPatArgs = tree.getNumArgs();

  if (numPatArgs != 0) {
    if (auto lastArg = tree.getArgAsNestedDag(numPatArgs - 1))
      if (lastArg.isLocationDirective()) {
        return std::make_pair(true, handleLocationDirective(lastArg));
      }
  }

  // If no explicit location is given, use the default, all fused, location.
  return std::make_pair(false, "odsLoc");
}

std::string PatternEmitter::handleOpCreation(DagNode tree, int resultIndex,
                                             int depth) {
  LLVM_DEBUG(llvm::dbgs() << "create op for pattern: ");
  LLVM_DEBUG(tree.print(llvm::dbgs()));
  LLVM_DEBUG(llvm::dbgs() << '\n');

  Operator &resultOp = tree.getDialectOp(opMap);
  auto numOpArgs = resultOp.getNumArgs();
  auto numPatArgs = tree.getNumArgs();

  bool hasLocationDirective;
  std::string locToUse;
  std::tie(hasLocationDirective, locToUse) = getLocation(tree);

  auto inPattern = numPatArgs - hasLocationDirective;
  if (numOpArgs != inPattern) {
    PrintFatalError(loc,
                    formatv("resultant op '{0}' argument number mismatch: "
                            "{1} in pattern vs. {2} in definition",
                            resultOp.getOperationName(), inPattern, numOpArgs));
  }

  // A map to collect all nested DAG child nodes' names, with operand index as
  // the key. This includes both bound and unbound child nodes.
  ChildNodeIndexNameMap childNodeNames;

  // First go through all the child nodes who are nested DAG constructs to
  // create ops for them and remember the symbol names for them, so that we can
  // use the results in the current node. This happens in a recursive manner.
  for (int i = 0, e = tree.getNumArgs() - hasLocationDirective; i != e; ++i) {
    if (auto child = tree.getArgAsNestedDag(i))
      childNodeNames[i] = handleResultPattern(child, i, depth + 1);
  }

  // The name of the local variable holding this op.
  std::string valuePackName;
  // The symbol for holding the result of this pattern. Note that the result of
  // this pattern is not necessarily the same as the variable created by this
  // pattern because we can use `__N` suffix to refer only a specific result if
  // the generated op is a multi-result op.
  std::string resultValue;
  if (tree.getSymbol().empty()) {
    // No symbol is explicitly bound to this op in the pattern. Generate a
    // unique name.
    valuePackName = resultValue = getUniqueSymbol(&resultOp);
  } else {
    resultValue = std::string(tree.getSymbol());
    // Strip the index to get the name for the value pack and use it to name the
    // local variable for the op.
    valuePackName = std::string(SymbolInfoMap::getValuePackName(resultValue));
  }

  // Create the local variable for this op.
  os << formatv("{0} {1};\n{{\n", resultOp.getQualCppClassName(),
                valuePackName);

  // Right now ODS don't have general type inference support. Except a few
  // special cases listed below, DRR needs to supply types for all results
  // when building an op.
  bool isSameOperandsAndResultType =
      resultOp.getTrait("::mlir::OpTrait::SameOperandsAndResultType");
  bool useFirstAttr =
      resultOp.getTrait("::mlir::OpTrait::FirstAttrDerivedResultType");

  if (isSameOperandsAndResultType || useFirstAttr) {
    // We know how to deduce the result type for ops with these traits and we've
    // generated builders taking aggregate parameters. Use those builders to
    // create the ops.

    // First prepare local variables for op arguments used in builder call.
    createAggregateLocalVarsForOpArgs(tree, childNodeNames, depth);

    // Then create the op.
    os.scope("", "\n}\n").os << formatv(
        "{0} = rewriter.create<{1}>({2}, tblgen_values, tblgen_attrs);",
        valuePackName, resultOp.getQualCppClassName(), locToUse);
    return resultValue;
  }

  bool usePartialResults = valuePackName != resultValue;

  if (usePartialResults || depth > 0 || resultIndex < 0) {
    // For these cases (broadcastable ops, op results used both as auxiliary
    // values and replacement values, ops in nested patterns, auxiliary ops), we
    // still need to supply the result types when building the op. But because
    // we don't generate a builder automatically with ODS for them, it's the
    // developer's responsibility to make sure such a builder (with result type
    // deduction ability) exists. We go through the separate-parameter builder
    // here given that it's easier for developers to write compared to
    // aggregate-parameter builders.
    createSeparateLocalVarsForOpArgs(tree, childNodeNames);

    os.scope().os << formatv("{0} = rewriter.create<{1}>({2}", valuePackName,
                             resultOp.getQualCppClassName(), locToUse);
    supplyValuesForOpArgs(tree, childNodeNames, depth);
    os << "\n  );\n}\n";
    return resultValue;
  }

  // If depth == 0 and resultIndex >= 0, it means we are replacing the values
  // generated from the source pattern root op. Then we can use the source
  // pattern's value types to determine the value type of the generated op
  // here.

  // First prepare local variables for op arguments used in builder call.
  createAggregateLocalVarsForOpArgs(tree, childNodeNames, depth);

  // Then prepare the result types. We need to specify the types for all
  // results.
  os.indent() << formatv("::mlir::SmallVector<::mlir::Type, 4> tblgen_types; "
                         "(void)tblgen_types;\n");
  int numResults = resultOp.getNumResults();
  if (numResults != 0) {
    for (int i = 0; i < numResults; ++i)
      os << formatv("for (auto v: castedOp0.getODSResults({0})) {{\n"
                    "  tblgen_types.push_back(v.getType());\n}\n",
                    resultIndex + i);
  }
  os << formatv("{0} = rewriter.create<{1}>({2}, tblgen_types, "
                "tblgen_values, tblgen_attrs);\n",
                valuePackName, resultOp.getQualCppClassName(), locToUse);
  os.unindent() << "}\n";
  return resultValue;
}

void PatternEmitter::createSeparateLocalVarsForOpArgs(
    DagNode node, ChildNodeIndexNameMap &childNodeNames) {
  Operator &resultOp = node.getDialectOp(opMap);

  // Now prepare operands used for building this op:
  // * If the operand is non-variadic, we create a `Value` local variable.
  // * If the operand is variadic, we create a `SmallVector<Value>` local
  //   variable.

  int valueIndex = 0; // An index for uniquing local variable names.
  for (int argIndex = 0, e = resultOp.getNumArgs(); argIndex < e; ++argIndex) {
    const auto *operand =
        resultOp.getArg(argIndex).dyn_cast<NamedTypeConstraint *>();
    // We do not need special handling for attributes.
    if (!operand)
      continue;

    raw_indented_ostream::DelimitedScope scope(os);
    std::string varName;
    if (operand->isVariadic()) {
      varName = std::string(formatv("tblgen_values_{0}", valueIndex++));
      os << formatv("::mlir::SmallVector<::mlir::Value, 4> {0};\n", varName);
      std::string range;
      if (node.isNestedDagArg(argIndex)) {
        range = childNodeNames[argIndex];
      } else {
        range = std::string(node.getArgName(argIndex));
      }
      // Resolve the symbol for all range use so that we have a uniform way of
      // capturing the values.
      range = symbolInfoMap.getValueAndRangeUse(range);
      os << formatv("for (auto v: {0}) {{\n  {1}.push_back(v);\n}\n", range,
                    varName);
    } else {
      varName = std::string(formatv("tblgen_value_{0}", valueIndex++));
      os << formatv("::mlir::Value {0} = ", varName);
      if (node.isNestedDagArg(argIndex)) {
        os << symbolInfoMap.getValueAndRangeUse(childNodeNames[argIndex]);
      } else {
        DagLeaf leaf = node.getArgAsLeaf(argIndex);
        auto symbol =
            symbolInfoMap.getValueAndRangeUse(node.getArgName(argIndex));
        if (leaf.isNativeCodeCall()) {
          os << std::string(
              tgfmt(leaf.getNativeCodeTemplate(), &fmtCtx.withSelf(symbol)));
        } else {
          os << symbol;
        }
      }
      os << ";\n";
    }

    // Update to use the newly created local variable for building the op later.
    childNodeNames[argIndex] = varName;
  }
}

void PatternEmitter::supplyValuesForOpArgs(
    DagNode node, const ChildNodeIndexNameMap &childNodeNames, int depth) {
  Operator &resultOp = node.getDialectOp(opMap);
  for (int argIndex = 0, numOpArgs = resultOp.getNumArgs();
       argIndex != numOpArgs; ++argIndex) {
    // Start each argument on its own line.
    os << ",\n    ";

    Argument opArg = resultOp.getArg(argIndex);
    // Handle the case of operand first.
    if (auto *operand = opArg.dyn_cast<NamedTypeConstraint *>()) {
      if (!operand->name.empty())
        os << "/*" << operand->name << "=*/";
      os << childNodeNames.lookup(argIndex);
      continue;
    }

    // The argument in the op definition.
    auto opArgName = resultOp.getArgName(argIndex);
    if (auto subTree = node.getArgAsNestedDag(argIndex)) {
      if (!subTree.isNativeCodeCall())
        PrintFatalError(loc, "only NativeCodeCall allowed in nested dag node "
                             "for creating attribute");
      os << formatv("/*{0}=*/{1}", opArgName,
                    handleReplaceWithNativeCodeCall(subTree, depth));
    } else {
      auto leaf = node.getArgAsLeaf(argIndex);
      // The argument in the result DAG pattern.
      auto patArgName = node.getArgName(argIndex);
      if (leaf.isConstantAttr() || leaf.isEnumAttrCase()) {
        // TODO: Refactor out into map to avoid recomputing these.
        if (!opArg.is<NamedAttribute *>())
          PrintFatalError(loc, Twine("expected attribute ") + Twine(argIndex));
        if (!patArgName.empty())
          os << "/*" << patArgName << "=*/";
      } else {
        os << "/*" << opArgName << "=*/";
      }
      os << handleOpArgument(leaf, patArgName);
    }
  }
}

void PatternEmitter::createAggregateLocalVarsForOpArgs(
    DagNode node, const ChildNodeIndexNameMap &childNodeNames, int depth) {
  Operator &resultOp = node.getDialectOp(opMap);

  auto scope = os.scope();
  os << formatv("::mlir::SmallVector<::mlir::Value, 4> "
                "tblgen_values; (void)tblgen_values;\n");
  os << formatv("::mlir::SmallVector<::mlir::NamedAttribute, 4> "
                "tblgen_attrs; (void)tblgen_attrs;\n");

  const char *addAttrCmd =
      "if (auto tmpAttr = {1}) {\n"
      "  tblgen_attrs.emplace_back(rewriter.getIdentifier(\"{0}\"), "
      "tmpAttr);\n}\n";
  for (int argIndex = 0, e = resultOp.getNumArgs(); argIndex < e; ++argIndex) {
    if (resultOp.getArg(argIndex).is<NamedAttribute *>()) {
      // The argument in the op definition.
      auto opArgName = resultOp.getArgName(argIndex);
      if (auto subTree = node.getArgAsNestedDag(argIndex)) {
        if (!subTree.isNativeCodeCall())
          PrintFatalError(loc, "only NativeCodeCall allowed in nested dag node "
                               "for creating attribute");
        os << formatv(addAttrCmd, opArgName,
                      handleReplaceWithNativeCodeCall(subTree, depth + 1));
      } else {
        auto leaf = node.getArgAsLeaf(argIndex);
        // The argument in the result DAG pattern.
        auto patArgName = node.getArgName(argIndex);
        os << formatv(addAttrCmd, opArgName,
                      handleOpArgument(leaf, patArgName));
      }
      continue;
    }

    const auto *operand =
        resultOp.getArg(argIndex).get<NamedTypeConstraint *>();
    std::string varName;
    if (operand->isVariadic()) {
      std::string range;
      if (node.isNestedDagArg(argIndex)) {
        range = childNodeNames.lookup(argIndex);
      } else {
        range = std::string(node.getArgName(argIndex));
      }
      // Resolve the symbol for all range use so that we have a uniform way of
      // capturing the values.
      range = symbolInfoMap.getValueAndRangeUse(range);
      os << formatv("for (auto v: {0}) {{\n  tblgen_values.push_back(v);\n}\n",
                    range);
    } else {
      os << formatv("tblgen_values.push_back(");
      if (node.isNestedDagArg(argIndex)) {
        os << symbolInfoMap.getValueAndRangeUse(
            childNodeNames.lookup(argIndex));
      } else {
        DagLeaf leaf = node.getArgAsLeaf(argIndex);
        auto symbol =
            symbolInfoMap.getValueAndRangeUse(node.getArgName(argIndex));
        if (leaf.isNativeCodeCall()) {
          os << std::string(
              tgfmt(leaf.getNativeCodeTemplate(), &fmtCtx.withSelf(symbol)));
        } else {
          os << symbol;
        }
      }
      os << ");\n";
    }
  }
}

static void emitRewriters(const RecordKeeper &recordKeeper, raw_ostream &os) {
  emitSourceFileHeader("Rewriters", os);

  const auto &patterns = recordKeeper.getAllDerivedDefinitions("Pattern");
  auto numPatterns = patterns.size();

  // We put the map here because it can be shared among multiple patterns.
  RecordOperatorMap recordOpMap;

  std::vector<std::string> rewriterNames;
  rewriterNames.reserve(numPatterns);

  std::string baseRewriterName = "GeneratedConvert";
  int rewriterIndex = 0;

  for (Record *p : patterns) {
    std::string name;
    if (p->isAnonymous()) {
      // If no name is provided, ensure unique rewriter names simply by
      // appending unique suffix.
      name = baseRewriterName + llvm::utostr(rewriterIndex++);
    } else {
      name = std::string(p->getName());
    }
    LLVM_DEBUG(llvm::dbgs()
               << "=== start generating pattern '" << name << "' ===\n");
    PatternEmitter(p, &recordOpMap, os).emit(name);
    LLVM_DEBUG(llvm::dbgs()
               << "=== done generating pattern '" << name << "' ===\n");
    rewriterNames.push_back(std::move(name));
  }

  // Emit function to add the generated matchers to the pattern list.
  os << "void LLVM_ATTRIBUTE_UNUSED populateWithGenerated(::mlir::MLIRContext "
        "*context, ::mlir::OwningRewritePatternList &patterns) {\n";
  for (const auto &name : rewriterNames) {
    os << "  patterns.insert<" << name << ">(context);\n";
  }
  os << "}\n";
}

static mlir::GenRegistration
    genRewriters("gen-rewriters", "Generate pattern rewriters",
                 [](const RecordKeeper &records, raw_ostream &os) {
                   emitRewriters(records, os);
                   return false;
                 });
