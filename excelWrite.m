function [writeIndex] = excelWrite (numIndex)
%convert numbers to ecxel column letters in alphabetical order, when
%the number is bigger add initial 'A' 
for ii=1:length(numIndex);
    if numIndex(ii)<=26
        writeIndex(ii)={char(numIndex(ii)-1+'A')};
    elseif numIndex(ii)>26 & numIndex(ii)<54
            writeIndex(ii)={['A',char(numIndex(ii)-27+'A')]};
            %limited to 'BZ'
    else writeIndex(ii)={['B',char(numIndex(ii)-54+'B')]};
    end
end
