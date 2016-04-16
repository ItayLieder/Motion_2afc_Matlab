function [ ] = playInstructions( instCELL )
global w black gray white



[Nr,Nc]=size(instCELL);
for jj=1:Nr
    clear str
    
    for ii=1:Nc
        if length(instCELL{jj,ii})>0
            str{ii}=sprintf(instCELL{jj,ii});
        end
    end
    
    message=[];
    for ii=1:length(str)
        message = [message,str{ii}];
    end
    
    DrawFormattedText(w, message,'center',300, white);
    Screen('Flip', w);
    
    menuPress();
end

DrawFormattedText(w, '+', 'center', 'center', white);
Screen('Flip', w);

end

