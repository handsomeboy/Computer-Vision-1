function bits_array = detectBits(binary_img, ref)
    maximum=max(ref,[],1);
    minimum=min(ref,[],1);
    p=norm(maximum(1)-minimum(1));
    q=norm(maximum(2)-minimum(2));
    discretize=binary_img;
    for i=1:8
      m(i)=round(minimum(1)+(i-1)/8*p);
      n(i)=round(minimum(2)+(i-1)/8*q);
    end

    for i=1:8
       for j=minimum(2):maximum(2)
           discretize((m(i)),j) = 1; 
       end
    end  


    for j=1:8
       for i=minimum(1):maximum(1)
           discretize(i,n(j)) = 1; 
       end
    end

    m(9)=maximum(1);
    n(9)=maximum(2);
    value=0;


    for i=1:8
        for j=1:8  
               length=0;
               for k=(m(i):m(i+1))
                  breadth=0;
                  length=length+1;
                  for l=(n(j):n(j+1))
                  breadth=breadth+1;
                    value=value+binary_img(k,l);
                  end
               end
               tolerance=value;
               value=value-tolerance;
               if((tolerance+30)>(length*breadth))
                 bits_array(i,j)=1;
               else
                 bits_array(i,j)=0;
               end
        end
    end
end