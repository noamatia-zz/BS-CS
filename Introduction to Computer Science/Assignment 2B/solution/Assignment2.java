
public class Assignment2 {

	//1
	public static boolean isSquareMatrix(boolean[][] matrix) {
		boolean output = true;
		if (matrix == null) {
			output = false;
		}
		for (int i = 0; output && i < matrix.length; i = i + 1) {
			if (matrix[i] == null || matrix[i].length != matrix.length)
				output = false;
		}
		return output;
	}

	//2
	public static boolean isSymmetricMatrix(boolean[][] matrix) {
		boolean output = true;
		for (int i = 0; output & i < matrix.length; i = i + 1) {
			for (int j = i + 1; j < matrix.length & output; j = j + 1) {
				if (matrix[i][j] != matrix[j][i]) {
					output = false;
				}
			}
		}
		return output;
	}

	//3
	public static boolean isAntiReflexiveMatrix(boolean[][] matrix) {
		boolean output = true;
		for (int i = 0; output & i < matrix.length; i = i + 1) {
			if (matrix[i][i] == true) {
				output = false;
			}
		}
		return output;
	}

	//4
	public static boolean isLegalInstance(boolean[][] matrix) {
		boolean output = isSquareMatrix(matrix) && isSymmetricMatrix(matrix) & isAntiReflexiveMatrix(matrix);
		return output;
	}

	//5
	public static boolean isPermutation(int[] array) {
		boolean output = true;
		for (int i = 0; i < array.length & output; i = i + 1) {
			if (array[i] > array.length - 1 | array[i] < 0) output = false;
			for (int j = i + 1; j < array.length & output; j = j + 1)
				if (array[i] == array[j]) output = false;
		}
		return output;
	}

	//6
	public static boolean hasLegalSteps(boolean[][] flights, int[] tour) {
		boolean output = true;
		if ((!(isLegalInstance(flights))) | (!isPermutation(tour))) output = false;
		else {
			if (!(flights[tour[0]][tour[tour.length - 1]])) output = false;
			for (int i = 0; i < tour.length - 1 & output; i = i + 1) {
				if (!(flights[tour[i]][tour[i + 1]])) output = false;
			}
		}
		return output;
	}

	//7
	public static boolean isSolution(boolean[][] flights, int[] tour) {
		boolean output;
		if (tour == null || tour.length != flights.length) output = false;
		else {
			output = isPermutation(tour) && hasLegalSteps(flights, tour) & tour[0] == 0;
		}
		return output;
	}

	// Task 8
	public static int[][] atLeastOne(int[] vars) {
		int[][] cnf = new int[1][vars.length];
		for (int i = 0; i < vars.length; i = i + 1) {
			cnf[0][i] = vars[i];
		}
		return cnf;
	}

	// Task 9
	public static int[][] atMostOne(int[] vars) {
		int Indcnf = 0;
		int[][] cnf = new int[((vars.length) * (vars.length - 1)) / 2][2];
		for (int i = 0; i < vars.length; i = i + 1) {
			for (int j = i + 1; j < vars.length; j = j + 1) {
				cnf[Indcnf][0] = -vars[i];
				cnf[Indcnf][1] = -vars[j];
				Indcnf = Indcnf + 1;
			}
		}
		return cnf;
	}

	// Task 10
	public static int[][] exactlyOne(int[] vars) {
		int[][] cnf1 = new int[1][vars.length];
		int[][] cnf2 = new int[(((vars.length) * (vars.length - 1)) / 2) + 1][2];
		int Indcnf = 0;
		for (int k = 0; k < vars.length; k = k + 1) {
			cnf1[0][k] = vars[k];
		}
		for (int i = 0; i < vars.length; i = i + 1) {
			for (int j = i + 1; j < vars.length; j = j + 1) {
				cnf2[Indcnf][0] = -vars[i];
				cnf2[Indcnf][1] = -vars[j];
				Indcnf = Indcnf + 1;
			}
		}
		cnf2[cnf2.length - 1] = cnf1[0];
		return cnf2;
	}

	// Task 11
	public static boolean[] solveExactlyOneForEachSet(int[][] varSets) {
		int nVars = 0;
		for (int i = 0; i < varSets.length; i = i + 1) {
			for (int j = 0; j < varSets[i].length; j = j + 1) {
				if (varSets[i][j] > nVars) nVars = varSets[i][j];
			}
		}
		SATSolver.init(nVars);
		for (int i = 0; i < varSets.length; i = i + 1) {
			int[][] clauses = exactlyOne(varSets[i]);
			SATSolver.addClauses(clauses);
		}
		boolean[] output = SATSolver.getSolution();
		if (output == null) {
			throw new RuntimeException("timeout");
		}
		return output;
	}

	// Task 12
	public static int[][] createVarsMap(int n) {
		int[][] map = new int[n][n];
		int value = 1;
		for (int i = 0; i < n; i = i + 1) {
			for (int j = 0; j < n; j = j + 1) {
				map[i][j] = value;
				value = value + 1;
			}
		}
		return map;
	}

	// Task 13
	public static int[][] oneCityInEachStep(int[][] map) {
		int index = 0;
		int size = ((map.length) * (map.length - 1) / 2 + 1) * map.length;
		int[][] CNFormulaOCIES = new int[size][2];
		for (int i = 0; i < map.length; i = i + 1) {
			for (int j = 0; j < map.length; j = j + 1) {
				for (int k = j + 1; k < map.length; k = k + 1) {
					CNFormulaOCIES[index][0] = -map[i][k];
					CNFormulaOCIES[index][1] = -map[i][j];
					index = index + 1;
				}
			}
		}
		for (int i = 0; i < map.length; i = i + 1) {
			CNFormulaOCIES[index] = map[i];
			index = index + 1;
		}
		return CNFormulaOCIES;
	}

	// Task 14
	public static int[][] fixSourceCity(int[][] map) {
		int[][] CNFormulaFSC = {{map[0][0]}};
		return CNFormulaFSC;
	}

	// Task 15
	public static int[][] eachCityIsVisitedOnce(int[][] map) {
		int[][] tmpmap = new int[map.length][map.length];
		for (int i = 0; i < map.length; i = i + 1) {
			for (int j = 0; j < map.length; j = j + 1) {
				tmpmap[map.length - 1 - j][i] = map[i][j];
			}
		}
		int[][] CNFormulaECIVO = oneCityInEachStep(tmpmap);
		return CNFormulaECIVO;
	}

	// Task 16
	public static int[][] noIllegalSteps(boolean[][] flights, int[][] map) {
		int counter = 0;
		for (int i = 0; i < flights.length; i = i + 1) {
			for (int j = 0; j < flights.length; j = j + 1) {
				if (flights[i][j] == false & i != j) counter = counter + 1;
			}
		}
		int counter0 = 0;
		for (int i = 1; i < flights.length; i = i + 1) {
			if (flights[i][0] == false) counter0 = counter0 + 1;
		}
		int size = (map.length - 1) * counter + counter0;
		int[][] CNFormulaNIS = new int[size][];
		int index = 0;
		for (int i = 0; i < flights.length; i = i + 1) {
			for (int j = 0; j < flights.length; j = j + 1) {
				if (i != j & flights[i][j] == false) {
					for (int m = 0; m < map.length - 1; m = m + 1) {
						CNFormulaNIS[index] = new int[2];
						CNFormulaNIS[index][0] = -map[m][i];
						CNFormulaNIS[index][1] = -map[m + 1][j];
						index = index + 1;
					}
				}
			}
		}
		for (int i = 1; i < flights.length; i = i + 1) {
			if (flights[i][0] == false) {
				CNFormulaNIS[index] = new int[1];
				CNFormulaNIS[index][0] = -map[map.length - 1][i];
				index = index + 1;
			}
		}
		return CNFormulaNIS;
	}

	// Task 17
	public static void encode(boolean[][] flights, int[][] map) {
		if (!isLegalInstance(flights) || map.length != flights.length)
			throw new RuntimeException("illegal input");
		boolean validmap = true;
		int counter = 1;
		for (int i = 0; i < map.length & validmap; i = i + 1) {
			if (map[i].length != map.length) validmap = false;
			for (int j = 0; j < map[i].length & validmap; j = j + 1) {
				if (map[i][j] != counter) {
					validmap = false;
				}
				counter = counter + 1;
			}
		}
		if (!validmap) throw new RuntimeException("illegal input");

		int nVars = (map.length) * (map.length);
		SATSolver.init(nVars);
		int[][] CNFormulaOCIES = oneCityInEachStep(map);
		int[][] CNFormulaFSC = fixSourceCity(map);
		int[][] CNFormulaECIVO = eachCityIsVisitedOnce(map);
		int[][] CNFormulaNIS = noIllegalSteps(flights, map);
		SATSolver.addClauses(CNFormulaOCIES);
		SATSolver.addClauses(CNFormulaFSC);
		SATSolver.addClauses(CNFormulaECIVO);
		SATSolver.addClauses(CNFormulaNIS);
	}


	// Task 18
	public static int[] decode(boolean[] assignment, int[][] map) {
		int[] tour = new int[map.length];
		int index = 0;
		for (int i = 0; i < assignment.length; i = i + 1) {
			if (assignment[i] == true) {
				for (int j = 0; j < map.length; j = j + 1) {
					for (int k = 0; k < map.length; k = k + 1) {
						if (i == map[j][k]) {
							tour[index] = k;
							index = index + 1;
						}
					}
				}
			}
		}
		return tour;
	}

	// Task 19
	public static int[] solve(boolean[][] flights) {
		int[][] map = createVarsMap(flights.length);
		encode(flights, map);
		boolean[] assignment = SATSolver.getSolution();
		if (assignment == null) {
			throw new RuntimeException("timeout");
		}
		int[] s;
		if (assignment.length == 0) s = null;
		else {
			s = decode(assignment, map);
			boolean t = isSolution(flights, s);
			if (!t) throw new RuntimeException("illegal solution");
		}
		return s;
	}

	// Task 20
	public static boolean solve2(boolean[][] flights) {
		if (!isLegalInstance(flights)) throw new RuntimeException("illegal input");
		boolean output;
		int [] s1= solve(flights);
		int [] s1r = new int [s1.length];
		for (int i=1; i<s1.length; i=i+1){
			s1r[s1.length-i]=s1[i];
		}
		int [][] map = createVarsMap(flights.length);
		int [] clauses1 = new int [s1.length];
		int[] cluses1r = new int[s1r.length];
		for (int i=0; i<map.length; i=i+1){
			clauses1 [i] = -map[i][s1[i]];
			cluses1r [i] = -map[i][s1r[i]];
		}
		int[][] clauses13 = oneCityInEachStep(map);
		int[][] clauses14 = fixSourceCity(map);
		int[][] clauses15 = eachCityIsVisitedOnce(map);
		int[][] clauses16 = noIllegalSteps(flights, map);
		int nVars = (map.length) * (map.length);
		SATSolver.init(nVars);
		SATSolver.addClauses(clauses13);
		SATSolver.addClauses(clauses14);
		SATSolver.addClauses(clauses15);
		SATSolver.addClauses(clauses16);
		SATSolver.addClause(cluses1r);
		SATSolver.addClause(clauses1);

		boolean[] assignment = SATSolver.getSolution();
		if (assignment == null) {
			throw new RuntimeException("timeout");
		}
		int[] s2;
		if (assignment.length == 0) output=false;
		else {
			s2 = decode(assignment, map);
			boolean t = isSolution(flights, s2);
			if (!t) throw new RuntimeException("illegal solution");
			output=true;
		}


		return output;


	}
}
