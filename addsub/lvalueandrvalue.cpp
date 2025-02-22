#include <iostream>
#include <utility> // For std::move and std::forward
using namespace std;

// Function accepting lvalue reference
void lvalueRefFunc(int& x) {
    cout << "Lvalue reference function called with " << x << endl;
}

// Function accepting rvalue reference
void rvalueRefFunc(int&& x) {
    cout << "Rvalue reference function called with " << x << endl;
}

// Class demonstrating move semantics
class Data {
public:
    int* ptr;
    
    // Constructor
    Data(int val) {
        ptr = new int(val);
        cout << "Constructor called, allocated resource" << endl;
    }
    
    // Copy Constructor (Deep Copy)
    Data(const Data& other) {
        ptr = new int(*other.ptr);
        cout << "Copy Constructor called (Deep Copy)" << endl;
    }
    
    // Move Constructor (Steals the resource)
    Data(Data&& other) noexcept {
        ptr = other.ptr;
        other.ptr = nullptr; // Nullify the source pointer
        cout << "Move Constructor called (Resource Moved)" << endl;
    }
    
    // Destructor
    ~Data() {
        delete ptr;
        cout << "Destructor called, resource freed" << endl;
    }
};

// Function demonstrating perfect forwarding
template <typename T>
void forwardFunc(T&& arg) {
    rvalueRefFunc(std::forward<T>(arg));
}

int main() {
    int a = 10; // 'a' is an lvalue
    lvalueRefFunc(a); // Calls lvalue function
    
    lvalueRefFunc(a); // Lvalue function
    rvalueRefFunc(20); // Rvalue function (temporary object)
    rvalueRefFunc(std::move(a)); // Move a's value
    
    // Demonstrate move semantics
    Data d1(100); // Constructor
    Data d2 = std::move(d1); // Move constructor
    
    // Perfect forwarding
    int x = 50;
    forwardFunc(x); // Passes lvalue
    forwardFunc(50); // Passes rvalue
    
    return 0;
}