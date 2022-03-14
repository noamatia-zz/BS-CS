
public class KQueens {

    //Use these constants in your code
    final static int QUEEN = 1;
    final static int WALL = -1;
    final static int EMPTY = 0;


    /**
     * Checks if the input parameters are valid
     *
     * @param k number of queens
     * @param rows number of rows to be on a board
     * @param cols number of columns to be on a board
     * @param walls locations of walls on a board
     * @return true if all parameters are valid, false otherwise.
     */
    public static boolean isValidInput(int k, int rows, int cols, int[][] walls){
        boolean output=false;
        int counter =0;
        if (rows>=1 & cols>=1 & k>=1 & walls!=null && walls.length==rows) output =true;
        for (int i=0; output && i<walls.length ; i=i+1){
            if (walls[i]==null) {output=false;}
            for (int j=0;output && j<walls[i].length; j=j+1){
                if(walls[i][j]>=cols){output=false;}
                counter=counter+1;
            }

        }
        if(output & (rows*cols-counter)<k) output=false;
        return output;//replace with relevant return statement
    }

    /**
     * Creates a board of size rows x cols with walls
     *
     * @param rows number of rows in board. Assume valid value.
     * @param cols number of columns in board. Assume valid value.
     * @param walls locations of walls on board. Assume valid value.
     * @return rows x cols board with walls
     */
    public static int[][] createBoard(int rows, int cols, int[][] walls){
        int[][] output= new int [rows][cols];
        for (int i=0; i<walls.length ; i=i+1) {
            for (int j = 0; j < walls[i].length; j = j + 1) {
                output[i][walls[i][j]] = WALL;
            }
        }
        return output;//replace with relevant return statement
    }

    /**
     * Print the representation of a board with queens and walls
     *
     * @param board to be printed. Assume valid value.
     */
    public static void printBoard(int[][] board) {
        if (board.length == 0) {
            System.out.print("There is no solution");
        } else {
            for (int i = 0; i < board.length; i = i + 1) {
                if (i > 0)
                    System.out.println();
                for (int j = 0; j < board[i].length; j = j + 1) {
                    if (board[i][j] == EMPTY)
                        System.out.print("* ");
                      else {
                        if (board[i][j] == WALL)
                            System.out.print("X ");
                          else {
                            System.out.print("Q ");
                        }
                    }

                }
            }

        }
    }

    /**
     * Validate that the walls in board match the walls locations in walls
     *
     * @param walls locations of walls in board. Assume valid value.
     * @param board a board with walls
     * @return true if walls on boards match the walls locations, false otherwise
     */
    public static boolean validateWalls(int[][] walls, int[][] board){
        //checking the validity of board
        boolean output = true;
        int NumOfCols=0;
        if (board == null || board.length==0) {
            output = false;
        }
        if (output) NumOfCols=board[0].length;
        for (int i = 0; output && i < board.length; i = i + 1) {
            if (board[i] == null || board[i].length==0 | board[i].length != NumOfCols) output = false;
                for (int j = 0; output && j < board[i].length; j = j + 1){
                    if (board[i][j]!=QUEEN & board[i][j]!=WALL & board[i][j]!=EMPTY) output=false;
                }

        }
        for (int i=0; output && i<walls.length; i=i+1) {
            for (int j = 0; output && j < walls[i].length; j = j + 1) {
                if (board[i][walls[i][j]] != WALL) output = false;
            }
        }
        return output;//replace with relevant return statement
    }



    /**
     * Check if the queen located in board[row][col] is threatened by another queen on the board
     *
     * @param board a queen is located on this board
     * @param row the row in which the queen is located
     * @param col the column in which the queen is located
     * @return true if queen is threatened, false otherwise
     */
    public static boolean isQueenThreatened(int[][] board, int row, int col){
        boolean output=false;
        int lastInd = board.length-1;
        boolean WallFounded=false;
        //checking threat to the right
        for(int i=col+1; !output & !WallFounded & i<=lastInd; i=i+1) {
            if (board[row][i] == WALL) WallFounded = true;
            if (board[row][i] == QUEEN) output = true;
        }
        WallFounded=false;
        //checking threat to the left
        for(int i=col-1; !output & !WallFounded & i>=0; i=i-1) {
            if (board[row][i] == WALL) WallFounded = true;
            if (board[row][i] == QUEEN) output = true;
        }
        WallFounded=false;
        //checking threat to the up
        for(int i=row-1; !output & !WallFounded & i>=0; i=i-1) {
            if (board[i][col] == WALL) WallFounded = true;
            if (board[i][col] == QUEEN) output = true;
        }
        WallFounded=false;
        //checking threat to the down
        for(int i=row+1; !output & !WallFounded & i<=lastInd; i=i+1) {
            if (board[i][col] == WALL) WallFounded = true;
            if (board[i][col] == QUEEN) output = true;
        }
        WallFounded=false;
        //checking threat to the right-down
        int col2=col+1;
        for(int i=row+1; !output & !WallFounded & i<=lastInd; i=i+1) {
            if(col2<=lastInd) {
                if (board[i][col2] == WALL) WallFounded = true;
                if (board[i][col2] == QUEEN) output = true;
                col2 = col2 + 1;
            }
        }
        WallFounded=false;
        //checking threat to the left-down
        int col1=col-1;
        for(int i=row+1; !output & !WallFounded & i<=lastInd; i=i+1) {
            if(col1>=0) {
                if (board[i][col1] == WALL) WallFounded = true;
                if (board[i][col1] == QUEEN) output = true;
                col1 = col1 - 1;
            }
        }
        WallFounded=false;
        //checking threat to the right-up
        int col3=col+1;
        for(int i=row-1; !output & !WallFounded & i>=0; i=i-1) {
            if(col3<=lastInd) {
                if (board[i][col3] == WALL) WallFounded = true;
                if (board[i][col3] == QUEEN) output = true;
                col3 = col3 + 1;
            }
        }
        WallFounded=false;
        //checking threat to the left-up
        int col4=col-1;
        for(int i=row-1; !output & !WallFounded & i>=0; i=i-1) {
            if(col4>=0) {
                if (board[i][col4] == WALL) WallFounded = true;
                if (board[i][col4] == QUEEN) output = true;
                col4 = col4 - 1;
            }
        }
        return output;//replace with relevant return statement
    }


    /**
     * Check if board is a legal solution for k queens
     *
     * @param board a solution for the k-queens problem. Assume board not null and not empty, and each cell not null.
     * @param k number of queens that must be on the board. Assume k>=1.
     * @param rows number of rows that must be on the board. Assume rows>=1.
     * @param cols number of columns that must be on the board. Assume cols>=1.
     * @param walls locations of walls that must be on board. Assume valid value.
     * @return true if board is a legal solution for k queens, otherwise false
     */
    public static boolean isLegalSolution(int[][] board, int k, int rows, int cols, int[][] walls){
        boolean output=true;
        int QueensCounter=0;
        if(board.length!=rows) output=false;
        for (int i=0; output & i<board.length; i=i+1){
            if(board[i].length!=cols) output=false;
            for (int j=0; output & j<board[i].length; j=j+1){
                if (board[i][j]==QUEEN){
                    QueensCounter=QueensCounter+1;
                    if(isQueenThreatened(board,i,j)) output=false;
                }
                if (board[i][j]!=QUEEN & board[i][j]!=WALL & board[i][j]!=EMPTY) output=false;
            }
        }
        if (output) output= QueensCounter==k & validateWalls(walls, board);
        return output;//replace with relevant return statement
    }

    /**
     * Adds queen to cell board[row][col] if the board obtained by adding the queen is legal
     *
     * @param board represents a partial solution for k'<k queens. Assume valid value.
     * @param row queen must be added to this row. Assume valid value.
     * @param col queen must be added to this column. Assume valid value.
     * @return true if queen was added, otherwise false.
     */
    public static boolean addQueen(int[][] board, int row, int col){
        boolean output=true;
        if(board[row][col]==WALL|board[row][col]==QUEEN) output=false;
        else {
            int tmp = board[row][col];
            board[row][col] = QUEEN;
            if (isQueenThreatened(board, row, col)) {
                output = false;
                board[row][col] = tmp;
            }
        }
        return output;//replace with relevant return statement
    }

    /**
     * Solves the k queens problem.
     *
     * @param k number of queens to be located on the board
     * @param rows number of rows in the board
     * @param cols number of columns in the board
     * @param walls locations of walls on the board
     * @return board that is a legal solution, empty board if there is no solution
     */
    public static int[][] kQueens(int k, int rows, int cols, int[][] walls) {
        int[][] board;
        if (!isValidInput(k, rows, cols, walls)) board = new int[0][0];
        else {
            board = createBoard(rows, cols, walls);
            int numOfQueens = 0;
            boolean RecursionAns = kQueens(board, k, 0, 0, numOfQueens);
            if (!RecursionAns) {
                board = new int[0][0]; //if there is no solution return empty array
            }
        }
            return board;

    }


    /**
     * Recursive helper function for the k queens problem
     * @param board
     * @param k
     * @param row
     * @param col
     * @param numOfQueens
     * @return
     */
    private static boolean kQueens(int[][] board, int k, int row, int col, int numOfQueens) {
        final int LastRow = board.length-1;
        final int LastCol = board[0].length-1;
        if (numOfQueens == k) return true; //we succeeded in placing all of the queens!!!
        if((col==LastCol+1)&(row==LastRow)) return false; //we got off the array. reject this trial
        if(col==LastCol+1){ //go down a row
            row=row+1;
            col=0;
        }
        if(addQueen(board, row, col)) { //trying of placing a queen
            if (!kQueens(board, k, row, col + 1, numOfQueens + 1))
                //first recursive call - we placed the queen let's try to place the others that have not yet been place
                board[row][col] = EMPTY;//we failed to place the others, empty the cell
            else {
                return true;//we succeeded to place the others!!!
            }
        }
        return kQueens(board, k, row, col+1, numOfQueens);
        //second recursive call - we couldn't place the queen, let's try on the next cell
        }
}
