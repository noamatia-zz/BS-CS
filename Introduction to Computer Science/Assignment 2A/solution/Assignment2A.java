
public class Assignment2A {

    //1
    public static boolean isSquareMatrix(boolean[][] matrix){
        boolean output = true;
        if (matrix==null) {output = false;}
        for (int i=0; output && i<matrix.length; i=i+1) {
            if (matrix[i] == null || matrix[i].length != matrix.length)
                output = false;
        }
        return output;
    }

    //2
    public static boolean isSymmetricMatrix(boolean[][] matrix){
        boolean output = true;
        for (int i=0; output & i<matrix.length; i=i+1){
            for (int j=i+1; j<matrix.length & output; j=j+1){
                if (matrix[i][j]!=matrix[j][i]) {output = false;}
            }
        }
        return output;
    }

    //3
    public static boolean isAntiReflexiveMatrix(boolean[][] matrix){
        boolean output = true;
        for (int i=0; output & i<matrix.length; i=i+1) {
            if (matrix[i][i] == true) {
                output = false;
            }
        }
        return output;
    }

    //4
    public static boolean isLegalInstance(boolean[][] matrix){
        boolean output = isSquareMatrix(matrix) && isSymmetricMatrix(matrix) & isAntiReflexiveMatrix(matrix);
        return output;
    }

    //5
    public static boolean isPermutation(int[] array) {
        boolean output = true;
        for(int i=0; i<array.length & output; i=i+1) {
            if (array[i] > array.length - 1 | array[i] < 0) output = false;
            for (int j = i + 1; j < array.length & output; j = j + 1)
                if (array[i] == array[j]) output = false;
        }
        return output;
    }

    //6
    public static boolean hasLegalSteps(boolean[][] flights, int[] tour){
        boolean output = true;
        if (!(flights[tour[0]][tour[tour.length-1]])) output = false;
        for(int i =0; i<tour.length-1 & output; i=i+1){
            if(!(flights[tour[i]][tour[i+1]])) output = false;
        }
        return output;
    }

    //7
    public static boolean isSolution(boolean[][] flights, int[] tour){
        if (tour==null || tour.length!=flights.length) {
            throw new RuntimeException("tour is not a valid array");
        }
        boolean output = isPermutation(tour) && hasLegalSteps(flights, tour) & tour[0]==0;
        return output;
    }

}