// C++ program to illustrate the
// lvalue and rvalue
#include <iostream>
using namespace std;

// Driver Code
int main()
{
	int a = 10;

	// Declaring lvalue reference
	// (i.e variable a)
	int& lref = a;

	// Declaring rvalue reference
	int&& rref = 20;

	// Print the values
	cout << "lref = " << lref << endl;
	cout << "rref = " << rref << endl;

	// Value of both a
	// and lref is changed
	lref = 30;

	// Value of rref is changed
	rref = 40;
	cout << "lref = " << lref << endl;
	cout << "rref = " << rref << endl;

	// This line will generate an error
	// as l-value cannot be assigned
	// to the r-value references
	// int &&ref = a;
	return 0;
}
