// ========================================================
// L4 normal eval
import { Sexp } from "s-expression";
import { map } from "ramda";
import { CExp, Exp, IfExp, Program, parseL4Exp, LetExp, Binding, VarDecl } from "./L4-ast";
import { isAppExp, isBoolExp, isCExp, isDefineExp, isIfExp, isLitExp, isNumExp,
         isPrimOp, isProcExp, isStrExp, isVarRef, isLetExp } from "./L4-ast";
import { applyEnv, makeEmptyEnv, Env, makeExtEnv, Promise, makePromise, makeRecEnv } from './L4-env-normal';
import { applyPrimitive } from "./evalPrimitive";
import { isClosure, makeClosure, Value } from "./L4-value";
import { first, rest, isEmpty } from '../shared/list';
import { Result, makeOk, makeFailure, bind, mapResult, safe2 } from "../shared/result";
import { parse as p } from "../shared/parser";

export const L4normalEval = (exp: CExp, env: Env): Result<Value> =>
    isNumExp(exp) ? makeOk(exp.val) :
    isBoolExp(exp) ? makeOk(exp.val) :
    isStrExp(exp) ? makeOk(exp.val) :
    isPrimOp(exp) ? makeOk(exp) :
    isVarRef(exp) ? bind(applyEnv(env, exp.var), (promise: Promise) => L4normalEval(promise.exp, promise.env)) :
    isLitExp(exp) ? makeOk(exp.val) : 
    isIfExp(exp) ? evalIf(exp, env) :
    isProcExp(exp) ? makeOk(makeClosure(exp.args, exp.body, env)) :
    isLetExp(exp) ? evalLet(exp, env) :
    isAppExp(exp) ? bind(L4normalEval(exp.rator, env), (proc: Value) => L4normalApplyProc(proc, exp.rands, env)) :
    makeFailure(`Bad ast: ${exp}`);

export const isTrueValue = (x: Value): boolean =>
    ! (x === false);

export const evalIf = (exp: IfExp, env: Env): Result<Value> =>
    bind(L4normalEval(exp.test, env),
         (test: Value) => isTrueValue(test) ? L4normalEval(exp.then, env) : L4normalEval(exp.alt, env));

export const L4normalApplyProc = (proc: Value, args: CExp[], env: Env): Result<Value> => {
    if (isPrimOp(proc)){
        const argVals: Result<Value[]> = mapResult((arg) => L4normalEval(arg, env), args);
        return bind(argVals, (args: Value[]) => applyPrimitive(proc, args));
    }else if (isClosure(proc)) {
        const vars = map((v: VarDecl) => v.var, proc.params);
        return L4normalEvalSeq(proc.body, makeExtEnv(vars, args.map((exp: CExp) => makePromise(exp, env)), proc.env));
    }else
        return makeFailure(`Bad proc applied ${proc}`);
};

export const L4normalEvalSeq = (exps: CExp[], env: Env): Result<Value> => {
    if (isEmpty(rest(exps)))
        return L4normalEval(first(exps), env);
    else {
        L4normalEval(first(exps), env);
        return L4normalEvalSeq(rest(exps), env);
    }
};

export const evalLet = (exp: LetExp, env: Env): Result<Value> => {
    const vars = map((b: Binding) => b.var.var, exp.bindings);
    const vals = map((b: Binding) => b.val, exp.bindings);
    return L4normalEvalSeq(exp.body, makeExtEnv(vars, vals.map((exp: CExp) => makePromise(exp, env)), env));
}

// Evaluate a sequence of expressions (in a program)
export const evalExps = (exps: Exp[], env: Env): Result<Value> =>
    isEmpty(exps) ? makeFailure("Empty program") :
    isDefineExp(first(exps)) ? evalDefineExps(first(exps), rest(exps), env) :
    evalCExps(first(exps), rest(exps), env);

export const evalCExps = (exp1: Exp, exps: Exp[], env: Env): Result<Value> =>
    isCExp(exp1) && isEmpty(exps) ? L4normalEval(exp1, env) :
    isCExp(exp1) ? bind(L4normalEval(exp1, env), _ => evalExps(exps, env)) :
    makeFailure("Never");

export const evalDefineExps = (def: Exp, exps: Exp[], env: Env): Result<Value> =>
    isDefineExp(def) && isProcExp(def.val) ? evalExps(exps, makeRecEnv([def.var.var], [def.val.args], [def.val.body], env)) :
    isDefineExp(def) ? evalExps(exps, makeExtEnv([def.var.var], [makePromise(def.val, env)], env)) :
    makeFailure("Unexpected " + def);

export const evalNormalProgram = (program: Program): Result<Value> =>
    evalExps(program.exps, makeEmptyEnv());

export const evalNormalParse = (s: string): Result<Value> =>
    bind(p(s),
         (parsed: Sexp) => bind(parseL4Exp(parsed),
                                (exp: Exp) => evalExps([exp], makeEmptyEnv())));
