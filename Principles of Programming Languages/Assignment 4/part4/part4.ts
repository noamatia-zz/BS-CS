export const f = (x: number): Promise<number> => {
    return new Promise (
        (resolve, reject) => {
        if (x!= 0) resolve(1/x);
        else reject("CAN NOT DIVIDE BY ZERO!");
        });
}

export const g = (x: number): Promise<number> => {
    return new Promise (
        (resolve, reject) => {
        if(true) resolve(x*x);
        else reject("NOT POSSIBLE!");
        });
}

export const h = (x: number): Promise<number> => {
    return g(x)
            .then((c) => {return f(c)})
            .catch();
}

// h(2).then(x=>console.log(x)).catch(x=>console.log(x));
// h(0).then(x=>console.log(x)).catch(x=>console.log(x));

export const slower = <T1, T2>(arr: [Promise<T1>, Promise<T2>]): Promise<string> => {
    return new Promise(
      (resolve, reject) => {      
        const f=(i:number)=>(value: T1 | T2)=>{
          done++;
          if(done===2){
            resolve(`(${i} , '${value}')`)
          }
        }
        let done = 0;
        arr[0].then(f(0)).catch(() => reject("0 FAILED!"))
        arr[1].then(f(1)).catch(() => reject("1 FAILED!"))
      });
}
// const promise1 = new Promise((resolve, reject) => {
//   setTimeout(resolve, 500, 'one');
// });
  
// const promise2 = new Promise((resolve, reject) => {
//   setTimeout(resolve, 100, 'two');
// });

// slower([promise1, promise2]).then((x) => console.log(x)).catch((x) => console.log(x));

