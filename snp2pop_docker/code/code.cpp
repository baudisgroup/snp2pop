#include <Rcpp.h>
#include <iostream>
#include <fstream>
using namespace Rcpp;
using namespace std;

// [[Rcpp::export]]
CharacterVector onelinerCpp (DataFrame fracb, DataFrame anno){
	int nr = fracb.nrows();
	NumericVector val = fracb[3];
	CharacterVector res(nr*2);
	CharacterVector alleleA = anno[4];
	CharacterVector alleleB = anno[5];
	for (int i = 0; i < nr; i++){
		if (val[i] < 0.15){
			res[i*2] = alleleA[i];
			res[i*2 + 1] = alleleA[i];
		} else if (val[i] >= 0.15 && val[i] <= 0.85) {
			res[i*2] = alleleA[i];
			res[i*2 + 1] = alleleB[i];
		} else if (val[i] > 0.85) {
			res[i*2] = alleleB[i];
			res[i*2 + 1] = alleleB[i];
		}
	}
	return res;
}

// [[Rcpp::export]]
void write_output_Cpp (CharacterVector x, string filename) {
	ofstream myfile;
	myfile.open(filename.c_str(), ios::app);
	int len = x.size();
	for (int i = 0; i < len-1; i++){
		myfile << x[i];
		myfile << " ";
	}
	myfile << x[len-1];
	myfile << "\n";
	myfile.close();
}