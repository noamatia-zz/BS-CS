/* Question 1 */

import { values } from "ramda";

export type Optional<T> = Some<T> | None;

export interface Some<T> {
    tag: "Some";
    value: T;
}

export interface None{
    tag: "None";
}

export const makeSome: (<T>(arg1: T) => Some<T>) = <T>(value: T): Some<T> => ({tag: "Some", value: value});
export const makeNone: (() => None) = (): None  => ({tag: "None"});

export const isSome: (<T>(arg1: Optional<T>) => arg1 is Some<T>) = <T>(x: Optional<T>): x is Some<T> => x.tag === "Some";
export const isNone: (<T>(arg1: Optional<T>) => arg1 is None) = <T>(x: Optional<T>): x is None => x.tag === "None";

/* Question 2 */
export const bind: (<T, U>(arg1: Optional<T>, arg2: (x: T) => Optional<U>) => Optional<U>) = <T, U>(Optional: Optional<T>, f: (x: T) => Optional<U>): Optional<U> => {  
    switch(Optional.tag){
        case "None": return makeNone();
        case "Some": return f(Optional.value);
        }
}




