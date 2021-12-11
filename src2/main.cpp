
// main.cpp
import speech;

import <iostream>;
import <cstdlib>;

int main() {
    if (std::rand() % 2) {
       std::cout << get_phrase_es() << '\n';
    } else {
        std::cout << get_phrase_en() << '\n';
    }
}

