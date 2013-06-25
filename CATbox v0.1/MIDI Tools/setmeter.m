function nm2 = setmeter(nmat,val)

if isempty(nmat) return; end

t=gettempo(nmat);
nm2=nmat;
nm2(:,1) = onset(nmat)*val;
nm2(:,2) = dur(nmat)*val;
nm2(:,6) = onset(nmat,'sec')*val;
nm2(:,7) = dur(nmat,'sec')*val;
