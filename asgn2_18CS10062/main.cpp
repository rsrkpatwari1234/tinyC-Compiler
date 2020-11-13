/*Name : RADHIKA PATWARI
  Roll : 18CS10062*/
  
#include <iostream>

using namespace std;

#include "toylib.h"

//maintaining max length of string  as 100
#define buff 100

int main(){

	cout << "FUNCTION 1 : Enter the string : " <<endl;
	//FUNCTION 1 : 
	char str[buff];
	cin >> str;
	int ans1 = printStringUpper(str);
	cout << "\nSize of string in upper case : " << ans1 << endl;


	cout << "\nFUNCTION 2 : Enter a hexadecimal value : " <<endl;
	//FUNCTION 2 :
	int hex_val;
	int ans2 = readHexInteger(&hex_val);
	//printing 'BAD' in case of invalid hexadecimal string
	if(ans2 < 0){
		cout << "BAD" << endl;
	}
	//printing 'GOOD' to indicate successful read
	//printing the hexadecimal value in decimal 
	else{
		cout << "GOOD" << endl;
		cout << "Hexadecimal number in decimal: " << hex_val << endl;
	}


	cout << "\nFUNCTION 3 : Enter a decimal num : " << endl;
	//FUNCTION 3 :
	int dec;
	cin>>dec;
	int ans3 = printHexInteger(dec);
	//printing 'BAD' in case of unsuccessful print by syscall
	//else printing the length of hexadecimal value
	if(ans3 < 0)
		cout << "\nBAD" <<endl;
	else
		cout << "\nlength of the hexadecimal value : " << ans3 << endl;


	
	cout << "\nFUNCTION 4 : Enter a floating point value :  "<<endl;
	//FUNCTION 4 :
	float fl_val;
	int ans4 = readFloat(&fl_val);
	//printing 'BAD' for unsuccessful read of float value else returnig floating value
	if(ans4 < 0){
		cout << "BAD" << endl;
	}
	else{
		cout << "GOOD" << endl;
		cout << "Floating Number : " << fl_val << endl;
	}

	cout << "\nFUNCTION 5 : Enter a float value : "<<endl;
	//FUNCTION 5 :
	float flt_val;
	cin >> flt_val;
	int ans5 = printFloat(flt_val);
	//printing 'BAD' for unsuccessful syscall else printing length of 
	//floating point string printed
	if(ans5 >= 0)
		cout << "\nlength of the floating point value : " << ans5 << endl;
	else
		cout << "\nBAD" << endl;

	return 0;
}