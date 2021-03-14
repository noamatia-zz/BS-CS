/* Question 3 */

export type Result<T> = Ok<T> | Failure;

export interface Ok<T> {
    tag: "Ok";
    value: T;
}

export interface Failure {
    tag: "Failure";
    message: string;
}

export const makeOk: (<T>(arg1: T) => Ok<T>) = <T>(value: T): Ok<T> => ({tag: "Ok", value: value});
export const makeFailure: ((arg1: string) => Failure) = (message: string): Failure  => ({tag: "Failure", message: message});

export const isOk: (<T>(arg1: Result<T>) => arg1 is Ok<T>) = <T>(x: Result<T>): x is Ok<T> => x.tag === "Ok";
export const isFailure: (<T>(arg1: Result<T>) => arg1 is Failure) = <T>(x: Result<T>): x is Failure => x.tag === "Failure";

/* Question 4 */
export const bind: (<T, U>(arg1: Result<T>, arg2: (x: T) => Result<U>) => Result<U>) = <T, U>(Result: Result<T>, f: (x: T) => Result<U>): Result<U> => {  
    switch(Result.tag){
        case "Failure": return makeFailure(Result.message);
        case "Ok": return f(Result.value);
        }
}

/* Question 5 */
interface User {
    name: string;
    email: string;
    handle: string;
}

const validateName = (user: User): Result<User> =>
    user.name.length === 0 ? makeFailure("Name cannot be empty") :
    user.name === "Bananas" ? makeFailure("Bananas is not a name") :
    makeOk(user);

const validateEmail = (user: User): Result<User> =>
    user.email.length === 0 ? makeFailure("Email cannot be empty") :
    user.email.endsWith("bananas.com") ? makeFailure("Domain bananas.com is not allowed") :
    makeOk(user);

const validateHandle = (user: User): Result<User> =>
    user.handle.length === 0 ? makeFailure("Handle cannot be empty") :
    user.handle.startsWith("@") ? makeFailure("This isn't Twitter") :
    makeOk(user);

export const naiveValidateUser: ((arg1: User) => Result<User>) = (user: User): Result<User>=>{
    const newResult1 = validateName(user);
    switch(newResult1.tag){
        case "Failure": return newResult1;
        case "Ok":{
            const newResult2 = validateEmail(user);
            switch(newResult2.tag){
                case "Failure": return newResult2;
                case "Ok": return validateHandle(user);
            }
        }
    }
}

export const monadicValidateUser: ((arg1: User) => Result<User>) = (user: User): Result<User> => bind(bind(validateName(user), validateEmail),validateHandle);
  