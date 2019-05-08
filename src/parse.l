%option c++

%x HEAD MID

%{

#include <iostream>
#include <stack>

using namespace std;

stack<int> indents;
indents.push(0);

int indent = 0;

%}

%%

<HEAD>" " {
  indent += 1;
}

<HEAD>"\t" {
  indent += 4;
}

<HEAD>. {
  
}
