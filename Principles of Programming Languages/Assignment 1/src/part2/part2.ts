import { map, compose } from "ramda";

/* Question 1 */
export const partition: (<T>(arg1: (x: T) => boolean, arg2: T[]) => T[][]) = <T>(pred: (x: T) => boolean, arr: T[]): T[][] => arr.reduce(([l, r]: T[][], curr: T) => pred(curr) ? [l, r]=[l.concat(curr),r] : [l, r]=[l,r.concat(curr)], [[],[]]);

/* Question 2 */
export const mapMat: (<T, U>(arg1: (x: T) => U, arg2: T[][]) => U[][]) = <T, U>(pred: (x: T) => U, mat: T[][]): U[][] => map(map(pred), mat);

/* Question 3 */
export const composeMany: (<T>(arg1: ((x:T)=>T)[]) => ((x:T)=>T)) = <T>(arr: ((x:T)=>T)[]): ((x:T)=>T) => arr.reduce((acc: ((x:T)=>T), curr: ((x:T)=>T)) => compose(acc, curr), (x:T)=>x);

/* Question 4 */
interface Languages {
    english: string;
    japanese: string;
    chinese: string;
    french: string;
}   

interface Stats {
    HP: number;
    Attack: number;
    Defense: number;
    "Sp. Attack": number;
    "Sp. Defense": number;
    Speed: number;
}

export interface Pokemon {
    id: number;
    name: Languages;
    type: string[];
    base: Stats;
}

export const maxSpeed: ((arg1: Pokemon[]) => Pokemon[]) = (Pokedex: Pokemon[]): Pokemon[] => Pokedex.filter((x:Pokemon) => x.base.Speed === maxSpeed2(Pokedex));

export const maxSpeed2: ((arg1: Pokemon[]) => number) = (Pokedex: Pokemon[]): number => Pokedex.reduce((acc: number, curr: Pokemon) => Math.max(acc, curr.base.Speed), 0);

export const grassTypes: ((arg1: Pokemon[]) => string[]) =(Pokedex: Pokemon[]): string[] => Pokedex.filter((x:Pokemon) => x.type.indexOf('Grass')>-1).map((x:Pokemon) => (x.name.english)).sort();

export const uniqueTypes: ((arg1: Pokemon[]) => string[]) = (Pokedex: Pokemon[]): string[] => Pokedex.reduce((acc: string[], curr: Pokemon) => acc.concat(curr.type.filter((x: string) => acc.indexOf(x) === -1)), []).sort();
