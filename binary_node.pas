namespace binary_node;

uses opengl;

type
    node = class
        name: string;
        left, right: real;
    end; 
    A = class
        x0: integer := 1;
        h: integer := 2; 
        procedure PrintNext;
        begin
            Print(x0);
            x0 *= h; 
        end;
    end;
end.