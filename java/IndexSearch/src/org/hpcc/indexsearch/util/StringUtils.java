package org.hpcc.indexsearch.util;

import java.text.NumberFormat;

public final class StringUtils {
	private static NumberFormat numberFormat = NumberFormat.getInstance();
	
	/**
	 * Calculate the edit distance (Levenshtein Distance) of two strings.
	 * @param s
	 * @param t
	 * @return int
	 */
	public static int editDistance(String s, String t) {
		int m = s.length();
		int n = t.length();
		int[][] d = new int[m + 1][n + 1];
		for (int i = 0; i <= m; i++) {
			d[i][0] = i;
		}
		for (int j = 0; j <= n; j++) {
			d[0][j] = j;
		}
		for (int j = 1; j <= n; j++) {
			for (int i = 1; i <= m; i++) {
				if (s.charAt(i - 1) == t.charAt(j - 1)) {
					d[i][j] = d[i - 1][j - 1];
				} else {
					d[i][j] = min((d[i - 1][j] + 1), (d[i][j - 1] + 1),
							(d[i - 1][j - 1] + 1));
				}
			}
		}
		return (d[m][n]);
	}

	private static int min(int a, int b, int c) {
		return (Math.min(Math.min(a, b), c));
	}
	
	public static String splitCamelCase(String value) {
		if (value != null)
			{
			  return value.replaceAll("_","").replaceAll(
		      String.format("%s|%s|%s",
		         "(?<=[A-Z])(?=[A-Z][a-z])",
		         "(?<=[^A-Z])(?=[A-Z])",
		         "(?<=[A-Za-z])(?=[^A-Za-z])"
		      ),
		      " "
		   );
		}
		else{
			return null;
		}
	}

	public static String insertCommasIntoNumber(int num) {
		return numberFormat.format(num);
	}

	public static String insertCommasIntoNumber(long num) {
		return numberFormat.format(num);
	}

	public static String insertCommasIntoNumber(float num) {
		return numberFormat.format(num);
	}

	public static String insertCommasIntoNumber(double num) {
		return numberFormat.format(num);
	}
	
	/** Disable */
	private StringUtils() {
	}
}
