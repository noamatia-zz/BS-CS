// L5-eval-box

import { map, repeat, zipWith, append, filter } from "ramda";
import { CExp, Exp, IfExp, LetrecExp, LetExp, ProcExp, Program, SetExp, isCExp, isValuesExp, isLetValuesExp, LetValuesExp, ValuesExp, parseL5, Binding2 } from './L5-ast';
import { Binding, VarDecl } from "./L5-ast";
import { isBoolExp, isLitExp, isNumExp, isPrimOp, isStrExp, isVarRef } from "./L5-ast";
import { parseL5Exp } from "./L5-ast";
import { isAppExp, isDefineExp, isIfExp, isLetrecExp, isLetExp,
         isProcExp, isSetExp } from "./L5-ast";
import { applyEnv, applyEnvBdg, globalEnvAddBinding, makeExtEnv, setFBinding,
         theGlobalEnv, Env, FBinding } from "./L5-env";
import { isClosure, makeClosure, Closure, Value, isCompoundSExp, CompoundSExp, SExpValue, isEmptySExp, makeCompoundSExp, makeEmptySExp, makeTuple } from "./L5-value";
import { isEmpty, first, rest, cons } from '../shared/list';
import { Result, makeOk, makeFailure, mapResult, safe2, bind, isOk } from "../shared/result";
import { parse as p } from "../shared/parser";
import { applyPrimitive } from "./evalPrimitive";

// ========================================================
// Eval functions

export const applicativeEval = (exp: CExp, env: Env): Result<Value> =>
    isNumExp(exp) ? makeOk(exp.val) :
    isBoolExp(exp) ? makeOk(exp.val) :
    isStrExp(exp) ? makeOk(exp.val) :
    isPrimOp(exp) ? makeOk(exp) :
    isVarRef(exp) ? applyEnv(env, exp.var) :
    isLitExp(exp) ? makeOk(exp.val) :
    isIfExp(exp) ? evalIf(exp, env) :
    isProcExp(exp) ? evalProc(exp, env) :
    isLetExp(exp) ? evalLet(exp, env) :
    isLetrecExp(exp) ? evalLetrec(exp, env) :
    isSetExp(exp) ? evalSet(exp, env) :
    isAppExp(exp) ? safe2((proc: Value, args: Value[]) => applyProcedure(proc, args))
                        (applicativeEval(exp.rator, env), mapResult(rand => applicativeEval(rand, env), exp.rands)) :
    isValuesExp(exp) ? evalValuesExp(exp, env) :
    isLetValuesExp(exp) ? evalLetValuesExp(exp, env) :
    makeFailure(`Bad L5 AST ${exp}`);

export const isTrueValue = (x: Value): boolean =>
    ! (x === false);

const evalIf = (exp: IfExp, env: Env): Result<Value> =>
    bind(applicativeEval(exp.test, env),
         (test: Value) => isTrueValue(test) ? applicativeEval(exp.then, env) : applicativeEval(exp.alt, env));

const evalProc = (exp: ProcExp, env: Env): Result<Closure> =>
    makeOk(makeClosure(exp.args, exp.body, env));

// KEY: This procedure does NOT have an env parameter.
//      Instead we use the env of the closure.
const applyProcedure = (proc: Value, args: Value[]): Result<Value> =>
    isPrimOp(proc) ? applyPrimitive(proc, args) :
    isClosure(proc) ? applyClosure(proc, args) :
    makeFailure(`Bad procedure ${JSON.stringify(proc)}`);

const applyClosure = (proc: Closure, args: Value[]): Result<Value> => {
    const vars = map((v: VarDecl) => v.var, proc.params);
    return evalSequence(proc.body, makeExtEnv(vars, args, proc.env));
}

// Evaluate a sequence of expressions (in a program)
export const evalSequence = (seq: Exp[], env: Env): Result<Value> =>
    isEmpty(seq) ? makeFailure("Empty sequence") :
    isDefineExp(first(seq)) ? evalDefineExps(first(seq), rest(seq)) :
    evalCExps(first(seq), rest(seq), env);
    
const evalCExps = (first: Exp, rest: Exp[], env: Env): Result<Value> =>
    isCExp(first) && isEmpty(rest) ? applicativeEval(first, env) :
    isCExp(first) ? bind(applicativeEval(first, env), _ => evalSequence(rest, env)) :
    makeFailure("Never");
    
// define always updates theGlobalEnv
// We also only expect defineExps at the top level.
// Eval a sequence of expressions when the first exp is a Define.
// Compute the rhs of the define, extend the env with the new binding
// then compute the rest of the exps in the new env.
const evalDefineExps = (def: Exp, exps: Exp[]): Result<Value> =>
    isDefineExp(def) ? bind(applicativeEval(def.val, theGlobalEnv),
                            (rhs: Value) => { globalEnvAddBinding(def.var.var, rhs);
                                              return evalSequence(exps, theGlobalEnv); }) :
    makeFailure("Unexpected " + def);

// Main program
export const evalProgram = (program: Program): Result<Value> =>
    evalSequence(program.exps, theGlobalEnv);

export const evalParse = (s: string): Result<Value> =>
    bind(bind(p(s), parseL5Exp), (exp: Exp) => evalSequence([exp], theGlobalEnv));

// LET: Direct evaluation rule without syntax expansion
// compute the values, extend the env, eval the body.
const evalLet = (exp: LetExp, env: Env): Result<Value> => {
    const vals = mapResult((v : CExp) => applicativeEval(v, env), map((b : Binding) => b.val, exp.bindings));
    const vars = map((b: Binding) => b.var.var, exp.bindings);
    return bind(vals, (vals: Value[]) => evalSequence(exp.body, makeExtEnv(vars, vals, env)));
}

//************************************************************************************************************ 

export const validaeCompound = (s: SExpValue): Result<CompoundSExp> =>
    isCompoundSExp(s) ? makeOk(s) :
    makeFailure("Unexpected");

export const applicativeEvalAndCompound = (val: CExp, env: Env): Result<CompoundSExp> =>{
    const cs = applicativeEval(val, env);
    if(isOk(cs))
        return validaeCompound(cs.value);
    else
    return makeFailure("Unexpected");
}

export const evalLetValuesExp = (exp: LetValuesExp, env: Env): Result<Value> => {
    const trees = mapResult((b: Binding2) => applicativeEvalAndCompound(b.val, env), exp.bindings);
    if(isOk(trees))
        return evalGoodLetValuesExp(trees.value, exp, env);
    else 
        return makeFailure("Unexpected");
}

export const concatTrees = (arr: SExpValue[], curr: CompoundSExp, other: CompoundSExp[]): SExpValue[] =>
    isEmpty(other) ? treeToArr(curr, arr) :
    concatTrees(treeToArr(curr, arr), first(other), rest(other));

export const concatVars = (arr:string[], curr: Binding2, other: Binding2[]): string[] =>
    isEmpty(other) ? arr.concat(map((v: VarDecl) => v.var, curr.var)) :
    concatVars(arr.concat(map((v: VarDecl) => v.var, curr.var)), first(other), rest(other));

export const evalGoodLetValuesExp = (css: CompoundSExp[], exp: LetValuesExp, env: Env): Result<Value> => {
    const vals = makeOk(filter(isNotEmptySExp ,concatTrees([], first(css), rest(css))));
    const vars = filter(isNotEmptyString, concatVars([], first(exp.bindings), rest(exp.bindings)));
    const valsSizes = map((x: CompoundSExp) => getSizeOfTree(x, 0), css);
    const varsSizes = map((b: Binding2) => b.var.length, exp.bindings);
    if(JSON.stringify(valsSizes)==JSON.stringify(varsSizes))
        return bind(vals, (vals: Value[]) => evalSequence(exp.body, makeExtEnv(vars, vals, env)));
    else
        return makeFailure("Sizes of vals and vars of let-value are not equals!");
}

export const isNotEmptySExp = (x: any): boolean => x.tag != "EmptySExp";

export const isNotEmptyString = (x: string): boolean => x != "p";

export const getSizeOfTree = (cs: CompoundSExp, num: number): number =>
    isEmptySExp(cs.val1) && isEmptySExp(cs.val2) ? num :
    isEmptySExp(cs.val1) && isCompoundSExp(cs.val2) ? getSizeOfTree(cs.val2, num) :
    isEmptySExp(cs.val2) ? num+1 :
    isCompoundSExp(cs.val2) ? getSizeOfTree(cs.val2, num+1) :
    -1;

export const treeToArr = (cs: CompoundSExp, res: SExpValue[]): SExpValue[] =>
    isEmptySExp(cs.val2) ? append(cs.val1, res) :
    isCompoundSExp(cs.val2) ? treeToArr(cs.val2, res.concat([cs.val1])) :
    [];

export const evalValuesExp = (exp: ValuesExp, env: Env): Result<Value> => {
    const vals = exp.vals.map((x: CExp) =>  applicativeEval(x, env));
    if(isEmpty(vals))
        return makeOk(makeCompoundSExp(makeEmptySExp(), makeEmptySExp()));
    else
        return buildTree(first(vals), rest(vals));
}

export const buildTree = (f: Result<SExpValue>, r: Result<SExpValue>[]): Result<CompoundSExp> =>
    isEmpty(r) ? bind(f, (s: SExpValue) => makeOk(makeCompoundSExp(s, makeEmptySExp()))) :
    isOk(f) ? bind(buildTree(first(r), rest(r)), (val2: CompoundSExp) => makeOk(makeCompoundSExp(f.value, val2))):
    makeFailure("Unexpected " + f);

//************************************************************************************************************ 


// LETREC: Direct evaluation rule without syntax expansion
// 1. extend the env with vars initialized to void (temporary value)
// 2. compute the vals in the new extended env
// 3. update the bindings of the vars to the computed vals
// 4. compute body in extended env
const evalLetrec = (exp: LetrecExp, env: Env): Result<Value> => {
    const vars = map((b) => b.var.var, exp.bindings);
    const vals = map((b) => b.val, exp.bindings);
    const extEnv = makeExtEnv(vars, repeat(undefined, vars.length), env);
    // @@ Compute the vals in the extended env
    const cvalsResult = mapResult((v: CExp) => applicativeEval(v, extEnv), vals);
    const result = bind(cvalsResult,
                        (cvals: Value[]) => makeOk(zipWith((bdg, cval) => setFBinding(bdg, cval), extEnv.frame.fbindings, cvals)));
    return bind(result, _ => evalSequence(exp.body, extEnv));
};

// L4-eval-box: Handling of mutation with set!
const evalSet = (exp: SetExp, env: Env): Result<void> =>
    safe2((val: Value, bdg: FBinding) => makeOk(setFBinding(bdg, val)))
        (applicativeEval(exp.val, env), applyEnvBdg(env, exp.var.var));

// console.log(evalParse("(values 1 2 #t)"));

// console.log(makeOk(makeTuple([1,2, true])));


