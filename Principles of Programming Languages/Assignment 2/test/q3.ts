import { isCompoundExp, isCExp, isProcExp, makeIfExp, isIfExp, isAppExp, ForExp, AppExp, Exp, Program, makeNumExp, makeAppExp, makeProcExp, isProgram, makeProgram, isDefineExp, makeDefineExp, CExp, isAtomicExp, CompoundExp, isExp, isForExp, makeForExp, isNumExp, NumExp} from "./L21-ast";
import { Result, makeOk, mapResult, bind, makeFailure, safe3, safe2 } from "../imp/result";
import { map } from 'ramda';

/*
Purpose: Transform L21 ForExp to L2 AppExp
Signature: for2app(forExp)
Type: [ForExp] -> [AppExp]
*/
export const for2app = (exp: ForExp): AppExp =>
    makeAppExp(makeProcExp([], map((x: number): AppExp => makeAppExp(makeProcExp([exp.var] ,  [exp.body]), [makeNumExp(x)]), rangeArr(exp.start.val, exp.end.val))), []);

export const rangeArr = (start: number, end: number, length: number = end - start+1): number[] =>
    Array.from({ length }, (_, i) => start + i);

/*
Purpose: Transform L21 AST to result of L2 AST, by transforming ForExp to AppExp using for2app
Signature: L21ToL2(l2Ast)
Type: [Exp | Program] -> [Result<Exp | Program>]
*/
export const L21ToL2 = (exp: Exp | Program): Result<Exp | Program> =>
    isProgram(exp) ? bind(mapResult(L21ToL2Exp, exp.exps), (exps: Exp[]) => makeOk(makeProgram(exps))) :
    isExp(exp) ? L21ToL2Exp(exp) :
    makeFailure(`Unknown expression: ${exp}`);   


export const L21ToL2Exp = (exp: Exp): Result<Exp> =>
    isDefineExp(exp) ? bind(L21ToL2CExp(exp.val), (val: CExp) => makeOk(makeDefineExp(exp.var, val))) :
    isCExp(exp) ? L21ToL2CExp(exp) :
    makeFailure(`Unknown expression: ${exp}`);

export const L21ToL2CExp = (exp: CExp): Result<CExp> =>
    isAtomicExp(exp) ? makeOk(exp) : 
    isCompoundExp(exp) ? L21ToL2CompoundExp(exp) :
    makeFailure(`Unknown expression: ${exp}`);

export const L21ToL2CompoundExp = (exp: CompoundExp): Result<CompoundExp> =>
    isAppExp(exp) ? safe2((rator: CExp, rands: CExp[]) => makeOk(makeAppExp(rator, rands)))
                    (L21ToL2CExp(exp.rator), mapResult(L21ToL2CExp, exp.rands)) :
    isIfExp(exp) ? safe3((test: CExp, then: CExp, alt: CExp) => makeOk(makeIfExp(test, then, alt)))
                    (L21ToL2CExp(exp.test), L21ToL2CExp(exp.then), L21ToL2CExp(exp.alt)) :
    isProcExp(exp) ? bind(mapResult(L21ToL2CExp, exp.body), (body: CExp[]) => makeOk(makeProcExp(exp.args, body))) :
    isForExp(exp) ? safe3((start: NumExp, end: NumExp, body: CExp) => makeOk(for2app(makeForExp(exp.var, start, end, body))))
                    (L21ToL2NumExp(exp.start), L21ToL2NumExp(exp.end), L21ToL2CExp(exp.body)) :
    makeFailure(`Unknown expression: ${exp}`);

export const L21ToL2NumExp = (exp: NumExp): Result<NumExp> =>
    isAtomicExp(exp) && isNumExp(exp) ? makeOk(exp):
    makeFailure(`Unknown expression: ${exp}`);





