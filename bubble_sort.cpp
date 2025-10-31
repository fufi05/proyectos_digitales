#include <iostream>

using namespace std;

void bubbleSort(int array[], int n){
    for(int i = 0; i < n-1; i++){
        for(int j = 0; j < n-i-1; j++){
            if(array[j] > array[j+1]){
                // Swap array[j] and array[j+1]
                int temp = array[j];
                array[j] = array[j+1];
                array[j+1] = temp;
            }
        }
    }
}

int main(){
    int array[] = {3,9,8,7,1};
    int n = size(array);
    bubbleSort(array, n);
    cout << "Sorted array: ";
    for(int i = 0; i < n; i++){
        cout << array[i] << " ";
    }
    return 0;
}