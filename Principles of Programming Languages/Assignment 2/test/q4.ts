import { Exp, Program, isProgram, isBoolExp, isNumExp, isVarRef, isPrimOp, isDefineExp, isProcExp, VarDecl, isIfExp, isAppExp, AppExp, PrimOp, CExp} from '../imp/L2-ast';
import { Result, makeOk, bind, mapResult, safe3, safe2, makeFailure } from '../imp/result';
import { map } from 'ramda';

/*
Purpose: Transform L2 AST to JavaScript program string
Signature: l2ToJS(l2Ast)
Type: [Exp | Program] -> [Result<string>]
*/
export const l2ToJS = (exp: Exp | Program): Result<string> => 
    isProgram(exp) ? 
                    exp.exps.length === 1 ? bind(l2ToJS(exp.exps[0]), (exps: string) => makeOk(`console.log(${exps});`)) :
                    bind(mapResult(l2ToJS, exp.exps), (exps: string[]) => makeOk(`${exps.slice(0, exps.length-1).join(";\n")};\nconsole.log(${exps[exps.length-1]});`)) :
    isBoolExp(exp) ? makeOk(exp.val ? `true` : `false`) :
    isNumExp(exp) ? makeOk(exp.val.toString()) :
    isVarRef(exp) ? makeOk(exp.var) :
    isDefineExp(exp) ? bind(l2ToJS(exp.val), (val: string) => makeOk(`const ${exp.var.var} = ${val}`)) : 
    isProcExp(exp) ?
                    exp.body.length === 1 ? bind(l2ToJS(exp.body[0]), (body: string) => makeOk(`((${map(v => v.var, exp.args).join(",")}) => ${body})`)) :
                    bind(mapResult(l2ToJS, exp.body), (body: string[]) => makeOk(`((${map(v => v.var, exp.args).join(",")}) => {${body.slice(0, body.length-1).join("; ")}; return ${body[body.length-1]};})`)) :
    isIfExp(exp) ? safe3((test: string, then: string, alt: string) => makeOk(`(${test} ? ${then} : ${alt})`))
                    (l2ToJS(exp.test), l2ToJS(exp.then), l2ToJS(exp.alt)) :
    isAppExp(exp) ? 
                    (isPrimOp(exp.rator) ? l2ToJSPrimOp(exp.rator, exp.rands) :
                    safe2((rator: string, rands: string[]) => makeOk(`${rator}(${rands.join(",")})`))
                    (l2ToJS(exp.rator), mapResult(l2ToJS, exp.rands))) :
    makeFailure(`Unknown expression: ${exp}`);   

export const l2ToJSPrimOp = (rator: PrimOp, rands: CExp[]): Result<string> =>
    rator.op === "not" ? bind(l2ToJS(rands[0]), (rand: string) => makeOk(`(!${rand})`)) :
    rator.op === "and" ? bind(mapResult(l2ToJS, rands), (rands: string[]) => makeOk(`(${rands.join(" && ")})`)) : 
    rator.op === "or" ? bind(mapResult(l2ToJS, rands), (rands: string[]) => makeOk(`(${rands.join(" || ")})`)) :
    rator.op === "number?" ? bind(l2ToJS(rands[0]), (rand: string) => makeOk(`(typeof ${rand} === "number")`)) :
    rator.op === "boolean?" ? bind(l2ToJS(rands[0]), (rand: string) => makeOk(`(typeof ${rand} === "boolean")`)) :
    (rator.op === "=" || rator.op === "eq?") ? bind(mapResult(l2ToJS, rands), (rands: string[]) => makeOk(`(${rands[0]} === ${rands[1]})`)) :
    bind(mapResult(l2ToJS, rands), (rands: string[]) => makeOk(`(${rands.join(` ${rator.op} `)})`));


