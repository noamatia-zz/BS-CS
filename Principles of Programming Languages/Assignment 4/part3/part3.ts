function* braid(gen1: Generator, gen2: Generator) {

    let iter1 = gen1.next();
    let iter2 = gen2.next();

    while(iter1.value!=undefined || iter2.value!=undefined){
        if(iter1.value!=undefined){
            yield iter1.value;
            iter1 = gen1.next();
        }
        if(iter2.value!=undefined){
            yield iter2.value;
            iter2 = gen2.next();
        }
    }   
}

function* biased(gen1: Generator, gen2: Generator) {
    let iter1a = gen1.next();
    let iter1b = gen1.next();
    let iter2 = gen2.next();

    while(iter1a.value!=undefined || iter2.value!=undefined){
        if(iter1a.value!=undefined){
            yield iter1a.value;
            iter1a = gen1.next();
        }
        if(iter1b.value!=undefined){
            yield iter1b.value;
            iter1b = gen1.next();
        }
        if(iter2.value!=undefined){
            yield iter2.value;
            iter2 = gen2.next();
        }
    }   
}

// function* Gen1() {
//     yield 3;
//     yield 6;
//     yield 9;
//     yield 12;
// }
// function* Gen2() {
//     yield 8;
//     yield 10;
// }

// function* take (n: number, gen:any){
//     for (let x of gen){
//         if(n<=0){
//             return;
//         }
//         else{
//             n--;
//             yield x;
//         }
//     }
// }

// let x = Gen1();
// let y = Gen2();
// for (let n of take(4, braid(x,y))) {
// console.log(n);
// }

// let x2 = Gen1();
// let y2 = Gen2(); 
// for (let n of biased(x2,y2)) {
//     console.log(n);
//     }
