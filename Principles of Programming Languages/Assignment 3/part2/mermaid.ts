import { parseL4, parseL4Exp } from "./L4-ast";
import { Result, makeOk, makeFailure, isOk, bind } from "../shared/result";
import { parse as p } from "../shared/parser";
import { Node, Graph, isGraph, isTD, isLR, GraphContent, Edge, isCompoundGraph, isNodeDecl, makeGraph, makeCompoundGraph, makeTD, makeAtomicGraph, makeNodeDecl, makeEdge, makeNodeRef, makeEdgeLabel, EdgeLabel } from "./mermaid-ast";
import { LetrecExp, LitExp, Binding, LetExp, ProcExp, VarDecl, IfExp, AppExp, isBoolExp, isPrimOp, NumExp, Parsed, Exp, isProgram, Program, CExp, DefineExp, isDefineExp, AtomicExp, isAtomicExp, isNumExp, isStrExp, StrExp, VarRef, BoolExp, PrimOp, CompoundExp, isAppExp, isIfExp, isProcExp, isLetExp, isLitExp, isLetrecExp, SetExp, isSetExp, isVarRef } from "./L4-ast";
import { flatten, map } from "ramda";
import { isClosure, SExpValue, isSymbolSExp, isEmptySExp, Closure, SymbolSExp, EmptySExp, CompoundSExp } from "./L4-value";
import { isNumber, isBoolean, isString } from "../shared/type-predicates";

// ========================================================
// L4 ASTs to Mermaid diagrams

export const mapL4toMermaid = (exp: Parsed): Result<Graph> =>
    isProgram(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(mapL4toMermaidProgram(exp)))) :
    isDefineExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidDefineExp(exp, iAmTheRoot))))) : 
    isAppExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidAppExp(exp, iAmTheRoot))))) : 
    isIfExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidIfExp(exp, iAmTheRoot))))) :
    isProcExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidProcExp(exp, iAmTheRoot))))) : 
    isLetExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidLetExp(exp, iAmTheRoot))))) :
    isLitExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidLitExp(exp, iAmTheRoot))))) :
    isLetrecExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidLetRecExp(exp, iAmTheRoot))))) :
    isSetExp(exp) ? makeOk(makeGraph(makeTD(), makeCompoundGraph(createRoot(mapL4toMermaidSetExp(exp, iAmTheRoot))))) :
    isNumExp(exp) ? makeOk(makeGraph(makeTD(), makeAtomicGraph(makeNodeDecl(makeVarGenNumExp(`NumExp`), `NumExp(${exp.val})`)))) :
    isBoolExp(exp) ? makeOk(makeGraph(makeTD(), makeAtomicGraph(makeNodeDecl(makeVarGenBoolExp(`BoolExp`), `BoolExp(${exp.val})`)))) :
    isStrExp(exp) ? makeOk(makeGraph(makeTD(), makeAtomicGraph(makeNodeDecl(makeVarGenStrExp(`StrExp`), `StrExp(${exp.val})`)))) :
    isPrimOp(exp) ? makeOk(makeGraph(makeTD(), makeAtomicGraph(makeNodeDecl(makeVarGenPrimOp(`PrimOp`), `PrimOp(${exp.op})`)))) :
    isVarRef(exp) ? makeOk(makeGraph(makeTD(), makeAtomicGraph(makeNodeDecl(makeVarGenVarRef(`VarRef`), `VarRef(${exp.var})`)))) :
    makeFailure(`Unknown expression: ${exp}`);

export const mapL4toMermaidProgram = (program: Program): Edge[] => {
    const expsId = makeVarGenExps(`Exps`);
    return flatten([makeEdge(makeNodeDecl(makeVarGenProgram(`Program`), `Program`), makeNodeDecl(expsId, arrLabel), makeEdgeLabel(`exps`)), 
                                                        map((exp: Exp): Edge[] => mapL4toMermaidExp(exp, expsId), program.exps)]);
}

export const mapL4toMermaidExp = (exp: Exp, expsId: string): Edge[] => 
    isDefineExp(exp) ? mapL4toMermaidDefineExp(exp, expsId) :
    mapL4toMermaidCExp(exp, expsId);

export const mapL4toMermaidDefineExp = (exp: DefineExp, expsId: string): Edge[] => {
    const defineExpId = makeVarGenDefineExp(`DefineExp`);
    return flatten([makeEdge(makeNodeRef(expsId), makeNodeDecl(defineExpId, `DefineExp`)),
                    mapL4toMermaidVarDecl(exp.var, defineExpId, makeEdgeLabel(`var`)),
                    mapL4toMermaidCExp(exp.val, defineExpId, makeEdgeLabel(`val`))]);
}

export const mapL4toMermaidBinding = (exp: Binding, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const bindingId = makeVarGenBinding(`Binding`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(bindingId, `Binding`), edgeLabel),
                    mapL4toMermaidVarDecl(exp.var, bindingId, makeEdgeLabel(`var`)),
                    mapL4toMermaidCExp(exp.val, bindingId, makeEdgeLabel(`val`))]);
}

export const mapL4toMermaidCExp = (exp: CExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => 
    isAtomicExp(exp) ? mapL4toMermaidAtomicExp(exp, fatherId, edgeLabel) :
    mapL4toMermaidCompundExp(exp, fatherId, edgeLabel);

export const mapL4toMermaidAtomicExp = (exp: AtomicExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] =>
    isNumExp(exp) ? mapL4toMermaidNumExp(exp, fatherId, edgeLabel) :
    isBoolExp(exp) ? mapL4toMermaidBoolExp(exp, fatherId, edgeLabel) : 
    isStrExp(exp) ? mapL4toMermaidStrExp(exp, fatherId, edgeLabel) :  
    isPrimOp(exp) ? mapL4toMermaidPrimOp(exp, fatherId, edgeLabel) :
    mapL4toMermaidVarRef(exp, fatherId, edgeLabel);

export const mapL4toMermaidNumExp = (exp: NumExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const numExpId = makeVarGenNumExp(`NumExp`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(numExpId, `"NumExp(${exp.val})"`), edgeLabel)];
}

export const mapL4toMermaidBoolExp = (exp: BoolExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const boolExpId = makeVarGenBoolExp(`BoolExp`);
    if(exp)
        return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(boolExpId, `"BoolExp(#t)"`), edgeLabel)];
    else
        return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(boolExpId, `"BoolExp(#f)"`), edgeLabel)];
}

export const mapL4toMermaidStrExp = (exp: StrExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const strExpId = makeVarGenStrExp(`StrExp`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(strExpId, `"StrExp(${exp.val})"`), edgeLabel)];
}

export const mapL4toMermaidPrimOp = (exp: PrimOp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const primOpExpId = makeVarGenPrimOp(`PrimOp`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(primOpExpId, `"PrimOp(${exp.op})"`), edgeLabel)];
}

export const mapL4toMermaidVarRef = (exp: VarRef, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const varRefExpId = makeVarGenVarRef(`VarRef`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(varRefExpId, `"VarRef(${exp.var})"`), edgeLabel)];
}

export const mapL4toMermaidVarDecl = (exp: VarDecl, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const varDeclId = makeVarGenVarDecl(`VarDecl`); 
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(varDeclId, `"VarDecl(${exp.var})"`), edgeLabel)];
}

export const mapL4toMermaidCompundExp = (exp: CompoundExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] =>
    isAppExp(exp) ? mapL4toMermaidAppExp(exp, fatherId, edgeLabel) :
    isIfExp(exp) ? mapL4toMermaidIfExp(exp, fatherId, edgeLabel) : 
    isProcExp(exp) ? mapL4toMermaidProcExp(exp, fatherId, edgeLabel) :  
    isLetExp(exp) ? mapL4toMermaidLetExp(exp, fatherId, edgeLabel) :
    isLitExp(exp) ? mapL4toMermaidLitExp(exp, fatherId, edgeLabel) :
    isLetrecExp(exp) ? mapL4toMermaidLetRecExp(exp, fatherId, edgeLabel) :
    mapL4toMermaidSetExp(exp, fatherId, edgeLabel);

export const mapL4toMermaidAppExp = (exp: AppExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const appExpId = makeVarGenAppExp(`AppExp`);
    const randsId = makeVarGenRands(`Rands`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(appExpId, `AppExp`), edgeLabel),
                    mapL4toMermaidCExp(exp.rator, appExpId, makeEdgeLabel(`rator`)),
                    makeEdge(makeNodeRef(appExpId), makeNodeDecl(randsId, arrLabel), makeEdgeLabel(`rands`)),
                    map((exp: CExp): Edge[] => mapL4toMermaidCExp(exp, randsId), exp.rands)]);    
}

export const mapL4toMermaidIfExp = (exp: IfExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const ifExpId = makeVarGenIfExp(`IfExp`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(ifExpId, `IfExp`), edgeLabel),
                    mapL4toMermaidCExp(exp.test, ifExpId, makeEdgeLabel(`test`)),
                    mapL4toMermaidCExp(exp.then, ifExpId, makeEdgeLabel(`then`)),
                    mapL4toMermaidCExp(exp.alt, ifExpId, makeEdgeLabel(`alt`))]);
}

export const mapL4toMermaidProcExp = (exp: ProcExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const procExpId = makeVarGenProcExp(`ProcExp`);
    const argsId = makeVarGenArgs(`Params`);
    const bodyId = makeVarGenBody(`Body`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(procExpId, `ProcExp`), edgeLabel),
                    makeEdge(makeNodeRef(procExpId), makeNodeDecl(argsId, arrLabel), makeEdgeLabel(`args`)),
                    makeEdge(makeNodeRef(procExpId), makeNodeDecl(bodyId, arrLabel), makeEdgeLabel(`body`)),
                    map((exp: VarDecl): Edge[] => mapL4toMermaidVarDecl(exp, argsId), exp.args),      
                    map((exp: CExp): Edge[] => mapL4toMermaidCExp(exp, bodyId), exp.body)]);
}

export const mapL4toMermaidLetExp = (exp: LetExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const letExpId = makeVarGenLetExp(`LetExp`);
    const bindingsId = makeVarGenBindings(`Bindings`);
    const bodyId = makeVarGenBody(`Body`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(letExpId, `LetExp`), edgeLabel),
                    makeEdge(makeNodeRef(letExpId), makeNodeDecl(bindingsId, arrLabel), makeEdgeLabel(`bindings`)),
                    map((exp: Binding): Edge[] => mapL4toMermaidBinding(exp, bindingsId), exp.bindings),
                    makeEdge(makeNodeRef(letExpId), makeNodeDecl(bodyId, arrLabel), makeEdgeLabel(`body`)),
                    map((exp: CExp): Edge[] => mapL4toMermaidCExp(exp, bodyId), exp.body)]);
}

export const mapL4toMermaidLitExp = (exp: LitExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const litExpId = makeVarGenLitExp(`LitExp`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(litExpId, "LitExp"), edgeLabel), 
                    mapL4toMermaidSExpValue(exp.val, litExpId, makeEdgeLabel(`val`))]);
}

export const mapL4toMermaidSExpValue = (exp: SExpValue, fatherId: string, edgeLabel?: EdgeLabel): Edge[] =>
    isNumber(exp) ? mapL4toMermaidSExpValueNumber(exp, fatherId, edgeLabel) :
    isBoolean(exp) ? mapL4toMermaidSExpValueBoolean(exp, fatherId, edgeLabel) :
    isString(exp) ? mapL4toMermaidSExpValueString(exp, fatherId, edgeLabel) :
    isPrimOp(exp) ? mapL4toMermaidPrimOp(exp, fatherId, edgeLabel) :   
    isClosure(exp) ? mapL4toMermaidSExpValueClosure(exp, fatherId, edgeLabel) :
    isSymbolSExp(exp) ? mapL4toMermaidSExpValueSymbolSExp(exp, fatherId, edgeLabel) :
    isEmptySExp(exp) ? mapL4toMermaidSExpValueEmptySExp(exp, fatherId, edgeLabel) :
    mapL4toMermaidSExpValueCompoundSExp(exp, fatherId, edgeLabel);

export const mapL4toMermaidSExpValueNumber = (exp: number, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const numberId = makeVarGenNumber(`number`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(numberId, `"number(${exp})"`), edgeLabel)];
}

export const mapL4toMermaidSExpValueBoolean = (exp: boolean, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const booleanId = makeVarGenBoolean(`boolean`);
    if(exp)
        return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(booleanId, `"boolean(#t)"`), edgeLabel)];
    else
        return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(booleanId, `"boolean(#f)"`), edgeLabel)];
}

export const mapL4toMermaidSExpValueString = (exp: string, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const stringId = makeVarGenString(`string`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(stringId, `"string(${exp})"`), edgeLabel)];
}

export const mapL4toMermaidSExpValueClosure = (exp: Closure, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    return [makeEdge(makeNodeRef("Error"), makeNodeRef("Closure will not be tested!"))];
}

export const mapL4toMermaidSExpValueSymbolSExp = (exp: SymbolSExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const symbolId = makeVarGenSymbolSExp(`Symbol`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(symbolId, `"Symbol(${exp.val})"`), edgeLabel)];
}

export const mapL4toMermaidSExpValueEmptySExp = (exp: EmptySExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const emptySExpId = makeVarGenEmptySExp(`EmptySExp`);
    return [makeEdge(makeNodeRef(fatherId), makeNodeDecl(emptySExpId, `"EmptySExp"`), edgeLabel)];
}

export const mapL4toMermaidSExpValueCompoundSExp = (exp: CompoundSExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const compoundSExpId = makeVarGenCompundSExp(`CompoundSExp`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(compoundSExpId, `"CompoundSExp"`), edgeLabel),
            mapL4toMermaidSExpValue(exp.val1, compoundSExpId, makeEdgeLabel(`val1`)),
            mapL4toMermaidSExpValue(exp.val2, compoundSExpId, makeEdgeLabel(`val2`))]);
}

export const mapL4toMermaidLetRecExp = (exp: LetrecExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const letRecExpId = makeVarGenLetRecExp(`LetrecExp`);
    const bindingsId = makeVarGenBindings(`Bindings`);
    const bodyId = makeVarGenBody(`Body`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(letRecExpId, `LetrecExp`), edgeLabel),
                    makeEdge(makeNodeRef(letRecExpId), makeNodeDecl(bindingsId, arrLabel), makeEdgeLabel(`bindings`)),
                    map((exp: Binding): Edge[] => mapL4toMermaidBinding(exp, bindingsId), exp.bindings),
                    makeEdge(makeNodeRef(letRecExpId), makeNodeDecl(bodyId, arrLabel), makeEdgeLabel(`body`)),
                    map((exp: CExp): Edge[] => mapL4toMermaidCExp(exp, bodyId), exp.body)]);
}

export const mapL4toMermaidSetExp = (exp: SetExp, fatherId: string, edgeLabel?: EdgeLabel): Edge[] => {
    const setExpId = makeVarGenSetExp(`SetExp`);
    const varRefId = makeVarGenVarRef(`VarRef`);
    return flatten([makeEdge(makeNodeRef(fatherId), makeNodeDecl(setExpId, `SetExp`), edgeLabel),
                    makeEdge(makeNodeRef(setExpId), makeNodeDecl(varRefId, `"VarRef(${exp.var.var})"`), makeEdgeLabel(`var`)),
                    mapL4toMermaidCExp(exp.val, setExpId, makeEdgeLabel(`val`))]);
}

export const createRoot = (edges: Edge[]): Edge[] => 
    [makeEdge(edges[0].to, edges[1].to, edges[1].label)].concat(edges.slice(2));
    
export const arrLabel = ":";
export const iAmTheRoot = "";
export const makeVarGen = (): (v: string) => string => {
    let count: number = 0;
    return (v: string) => {
        count++;
        return `${v}_${count}`;
    };
};

export const makeVarGenProgram = makeVarGen();
export const makeVarGenExps = makeVarGen();
export const makeVarGenDefineExp = makeVarGen();
export const makeVarGenVarDecl= makeVarGen();
export const makeVarGenNumExp = makeVarGen();
export const makeVarGenBoolExp = makeVarGen();
export const makeVarGenStrExp = makeVarGen();
export const makeVarGenPrimOp = makeVarGen();
export const makeVarGenVarRef = makeVarGen();
export const makeVarGenAppExp = makeVarGen();
export const makeVarGenRands = makeVarGen();
export const makeVarGenIfExp = makeVarGen();
export const makeVarGenProcExp = makeVarGen();
export const makeVarGenArgs = makeVarGen();
export const makeVarGenBody = makeVarGen();
export const makeVarGenLetExp = makeVarGen();
export const makeVarGenBindings = makeVarGen();
export const makeVarGenBinding = makeVarGen();
export const makeVarGenLitExp = makeVarGen();
export const makeVarGenNumber = makeVarGen();
export const makeVarGenBoolean = makeVarGen();
export const makeVarGenString = makeVarGen();
// export const makeVarGenClosure = makeVarGen();
export const makeVarGenSymbolSExp = makeVarGen();
export const makeVarGenEmptySExp = makeVarGen();
export const makeVarGenCompundSExp = makeVarGen();
export const makeVarGenLetRecExp = makeVarGen();
export const makeVarGenSetExp = makeVarGen();

export const unparseMermaid = (exp: Graph): Result<string> =>
    isGraph(exp) && isTD(exp.header) ? makeOk(`graph TD\n\t${unparseMermaidGraphContent(exp.graphContent)}`) :
    isGraph(exp) && isLR(exp.header) ? makeOk(`graph LR\n\t${unparseMermaidGraphContent(exp.graphContent)}`) :
    makeFailure(`Unknown expression: ${exp}`);

export const unparseMermaidGraphContent = (exp: GraphContent): string =>
    isCompoundGraph(exp) ? map(unparseMermaidEdge, exp.edges).join("\n\t") :
    `${exp.nodeDecl.id}["${exp.nodeDecl.label}"]`;

export const unparseMermaidEdge = (exp: Edge): string =>
    exp.label === undefined ? `${unparseMermaidNode(exp.from)} --> ${unparseMermaidNode(exp.to)}` : 
    `${unparseMermaidNode(exp.from)} -->|${exp.label.label}| ${unparseMermaidNode(exp.to)}`;

export const unparseMermaidNode = (exp:Node): string =>
    isNodeDecl(exp) ? `${exp.id}[${exp.label}]` :
    `${exp.id}`;

//---------------------------------------------------------------------------------------------------------------

export const L4toMermaid = (concrete: string): Result<string> =>
    concrete.substring(1, 3) === `L4` ? bind(bind(parseL4(concrete), mapL4toMermaid), unparseMermaid) :
    bind(bind(bind(p(concrete), parseL4Exp), mapL4toMermaid), unparseMermaid);

// const p1 = L4toMermaid(`(L4 1 #t "hello") `);
// const p2 = L4toMermaid(`(if #t 1 2)`);
// const p3= L4toMermaid(`(if (< x 2) (+ x 3) (lambda (x) (+ x 1)))`);
// const p4 =L4toMermaid(`(+ (+ 1 2) (- 4 3))`);
// const p5 = L4toMermaid(`( lambda (x y) (+ x y) 1 (- x y))`);
// const p6 = L4toMermaid(`(lambda (x y) ((lambda (x) (+ x y)) (+ x x)) 1)`);
// const p7 =L4toMermaid(`(letrec ((fact (lambda (n) (if (= n 0) 1 (* n (fact (- n 1)))))))(fact 3))`);
// const p8 =L4toMermaid(`(let ((x 3) (y 5)) 3)`);
// const p9 =L4toMermaid(`(let ((x 3) (y 5)) (+ x y))`);
// const p10 =L4toMermaid(`1`);
// const p11 =L4toMermaid(`(L4 (define square (lambda (x) (* x x))) (square 3))`);
// const p12 =L4toMermaid(`(L4 (define b (> 3 4)) (define x 5) (define f (lambda (y) (+ x y))) (define g (lambda (y) (* x y))) (if (not b) (f 3) (g 4)) ((lambda (x) (* x x)) 7))`);
// const p13 =L4toMermaid(`(L4 (lambda (z) (x z)))`);
// const p14 =L4toMermaid(`(L4 ((lambda (x) (number? x y)) x))`);
// const p15 =L4toMermaid(`(define my-list '(1 2 3 4 5))`);
// const p16 =L4toMermaid(`(+ 3 5 7)`);
// const p17 =L4toMermaid(`(L4 (set! x 5)  (+ x 5))`);

// isOk(p1)? console.log(p1.value) : '';
// isOk(p2)? console.log(p2.value) : '';
// isOk(p3)? console.log(p3.value) : '';
// isOk(p4)? console.log(p4.value) : '';
// isOk(p5)? console.log(p5.value) : '';
// isOk(p6)? console.log(p6.value) : '';
// isOk(p7)? console.log(p7.value) : '';
// isOk(p8)? console.log(p8.value) : '';
// isOk(p9)? console.log(p9.value) : '';
// isOk(p10)? console.log(p10.value) : '';
// isOk(p11)? console.log(p11.value) : '';
// isOk(p12)? console.log(p12.value) : '';
// isOk(p13)? console.log(p13.value) : '';
// isOk(p14)? console.log(p14.value) : '';
// isOk(p15)? console.log(p15.value) : '';
// isOk(p16)? console.log(p16.value) : '';
// isOk(p17)? console.log(p17.value) : '';