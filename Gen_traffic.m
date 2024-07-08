function [requiredDataArray1, requiredDataArray2] = Gen_traffic(Dur, SesRate, lambda_inter, lambda_process)
    % Loop over each SesRate value
        % fprintf('Current SesRate: %.1f\n', SesRate(k));

        % First run
        [arrivalTimes1, timeProcessArray1, totalTimeArray1, zeroOneArrays1, finalArray1, requiredDataArray1] = generateTimes(Dur, SesRate, lambda_inter, lambda_process);

        % Second run
        [arrivalTimes2, timeProcessArray2, totalTimeArray2, zeroOneArrays2, finalArray2, requiredDataArray2] = generateTimes(Dur, SesRate, lambda_inter, lambda_process);

        % Ensure the number of elements in the second run matches the first run
        numElements = min(length(arrivalTimes1), length(arrivalTimes2));
        arrivalTimes1 = arrivalTimes1(1:numElements);
        timeProcessArray1 = timeProcessArray1(1:numElements);
        totalTimeArray1 = totalTimeArray1(1:numElements);
        zeroOneArrays1 = zeroOneArrays1(1:numElements);
        requiredDataArray1 = requiredDataArray1(1:numElements);

        arrivalTimes2 = arrivalTimes2(1:numElements);
        timeProcessArray2 = timeProcessArray2(1:numElements);
        totalTimeArray2 = totalTimeArray2(1:numElements);
        zeroOneArrays2 = zeroOneArrays2(1:numElements);
        requiredDataArray2 = requiredDataArray2(1:numElements);

end


% Function to generate times based on SesRate
function [arrivalTimes, timeProcessArray, totalTimeArray, zeroOneArrays, finalArray, requiredDataArray] = generateTimes(Dur, SesRate, lambda_inter, lambda_process)
    TS = ceil(Dur / SesRate);
    arrivalTimes = [];
    timeProcessArray = [];
    currentArrivalTime = 0;
    
    while currentArrivalTime <= TS
        interArrivalTime = round(exprnd(1/lambda_inter));
        currentArrivalTime = currentArrivalTime + interArrivalTime;
        if currentArrivalTime > TS
            break;
        end
        arrivalTimes = [arrivalTimes, currentArrivalTime];
        processTime = poissrnd(lambda_process);
        timeProcessArray = [timeProcessArray, processTime];
    end
    
    totalTimeArray = arrivalTimes + timeProcessArray;
    validIndices = totalTimeArray <= TS;
    totalTimeArray = totalTimeArray(validIndices);
    arrivalTimes = arrivalTimes(validIndices);
    timeProcessArray = timeProcessArray(validIndices);
    numElements = length(totalTimeArray);
    arrivalTimes = arrivalTimes(1:numElements);
    timeProcessArray = timeProcessArray(1:numElements);
    totalTimeArray = totalTimeArray(1:numElements);
    zeroOneArrays = cell(1, length(arrivalTimes));
    
    for j = 1:length(arrivalTimes)
        zeroOneArray = zeros(1, TS);
        startIndex = max(1, arrivalTimes(j));
        endIndex = min(TS, totalTimeArray(j));
        if startIndex <= endIndex
            zeroOneArray(startIndex:endIndex) = 1;
        end
        zeroOneArrays{j} = zeroOneArray;
    end
    
    finalArray = zeros(1, TS);
    for j = 1:length(zeroOneArrays)
        finalArray = finalArray + zeroOneArrays{j};
    end
    
    requiredDataArray = timeProcessArray + 1;
end