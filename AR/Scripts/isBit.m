function SPIEN = isBit(bits_array)
    % Orientation of the marker
    orientation1 = 0; orientation2 = 0; orientation3 = 0; orientation4 = 0;
    SPIEN = 0;

    if bits_array(1:2,:) == zeros(2,8) 
        if bits_array(:,1:2) == zeros(8,2)
          if bits_array(7:8,:) == zeros(2,8)
              if bits_array(:,7:8) == zeros(8,2)
                  if (bits_array(6,6) || bits_array(6,3) || bits_array(3,6) || bits_array(3,3))
                    SPIEN = 1;
                  end
              end
          end
        end
    else
        SPIEN = 0;
    end
end


