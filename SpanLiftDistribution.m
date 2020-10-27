function SpanLiftDistribution(C)

[a,b]=size(C);
lift=zeros(a,1);
for iy=1:a
    area=0.0;
    for ix=1:b
        if(isnan(C(iy,ix))==0)
            lift(iy)=lift(iy)+C(iy,ix)*X(1,2)*Y(2,1);
            area=area+X(1,2)*Y(2,1);
        end
    end
    lift(iy)=lift(iy)/area;
end
end