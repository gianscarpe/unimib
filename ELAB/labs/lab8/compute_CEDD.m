function [ DescriptorVector ] = compute_CEDD(ImageRGB)

if ~isinteger(ImageRGB)
  error('L''immagine deve essere RGB');
end

ch = size(ImageRGB,3);

if (ch==1)
  ImageRGB=cat(3,ImageRGB,ImageRGb,ImageRGB);
end

DescriptorVector(1:144) = 0; % CEDD

T0 = 14;
T1 = 0.68;
T2 = 0.98;
T3 = 0.98;
T = -1;

Compact = 0; %false

% ImageRGB = imread(image_source);
width = size(ImageRGB,2);
height = size(ImageRGB,1);

MeanRed = 0; MeanGreen = 0; MeanBlue = 0;
Edges(1:6) = 0;
NeighborhoodArea1 = 0; NeighborhoodArea2 = 0; NeighborhoodArea3 = 0; NeighborhoodArea4 = 0;
Mask1 = 0; Mask2 = 0; Mask3 = 0; Mask4 = 0; Mask5 = 0;

Max = 0;
PixelCount(1:2,1:2) = 0;

Fuzzy10BinResultTable(1:10) = 0;
Fuzzy24BinResultTable(1:24) = 0;

%Thanasis
NumberOfBlocks = -1;
if (min(width,height) >=80) NumberOfBlocks=1600; end;
if ((min(width,height)<80)&&(min(width,height)>40)) NumberOfBlocks=400; end;
if min(width,height) <40 NumberOfBlocks=-1; end;

Step_X = 2;
Step_Y = 2;

if (NumberOfBlocks > 0)
    Step_X = floor(width / sqrt(NumberOfBlocks));
    Step_Y = floor(height / sqrt(NumberOfBlocks));
    
    if (mod(Step_X,2) ~= 0)
        Step_X = Step_X - 1;
    end
    if (mod(Step_Y,2) ~= 0)
       Step_Y = Step_Y - 1;
    end
end

%Thanasis

CororRed(1: Step_X*Step_Y) = 0;
CororGreen(1: Step_X*Step_Y) = 0;
CororBlue(1: Step_X*Step_Y) = 0;
CororRedTemp(1: Step_X*Step_Y) = 0;
CororGreenTemp(1: Step_X*Step_Y) = 0;
CororBlueTemp(1: Step_X*Step_Y) = 0;

% for i=1:height
%     for j=1:width
%         ImageGridRed(j,i) = double(ImageRGB(i,j,1));
%         ImageGridGreen(j,i) = double(ImageRGB(i,j,2));
%         ImageGridBlue(j,i) = double(ImageRGB(i,j,3));
%         ImageGrid(j,i) = 0.299 * double(ImageRGB(i,j,1)) + 0.587 * double(ImageRGB(i,j,2)) + 0.114 * double(ImageRGB(i,j,3));
%     end
% end

ImageGridRed = double(ImageRGB(:,:,1))';
ImageGridGreen = double(ImageRGB(:,:,2))';
ImageGridBlue = double(ImageRGB(:,:,3))';
% ImageGridRed = importdata('ImageGridRedC#.txt')';
% ImageGridGreen = importdata('ImageGridGreenC#.txt')';
% ImageGridBlue = importdata('ImageGridBlueC#.txt')';
ImageGrid = 0.299 * ImageGridRed + 0.587 * ImageGridGreen + 0.114 * ImageGridBlue;

% ImageGridRed(1:width,1:height) = double(ImageRGB(1:height,1:width,1));
% ImageGridGreen(1:width,1:height) = double(ImageRGB(1:height,1:width,2));
% ImageGridBlue(1:width,1:height) = double(ImageRGB(1:height,1:width,3));
% ImageGrid(1:width,1:height) = 0.299 * double(ImageRGB(1:height,1:width,1)) + 0.587 * double(ImageRGB(1:height,1:width,2)) + 0.114 * double(ImageRGB(1:height,1:width,3));

%Thanasis
TemoMAX_X = Step_X *floor(width /2);
TemoMAX_Y = Step_Y *floor(height /2);
if NumberOfBlocks>0
    TemoMAX_X = Step_X * sqrt(NumberOfBlocks);
    TemoMAX_Y = Step_Y * sqrt(NumberOfBlocks);
end
%Thanasis

for y= 1:Step_Y:TemoMAX_Y
    for x= 1:Step_X:TemoMAX_X
        MeanRed = 0; MeanGreen = 0; MeanBlue = 0;
        NeighborhoodArea1 = 0; NeighborhoodArea2 = 0; NeighborhoodArea3 = 0; NeighborhoodArea4 = 0;
        Edges(1:6) = -1;
        
        TempSum = 1;
        
        for i= 1:2
            for j= 1:2
                PixelCount(i,j) = 0;
            end
        end
        
        for i= y:1:y+Step_Y-1
            for j= x:1:x+Step_X-1
                CororRed(TempSum) = ImageGridRed(j, i);
                CororGreen(TempSum) = ImageGridGreen(j, i);
                CororBlue(TempSum) = ImageGridBlue(j, i);

                CororRedTemp(TempSum) = ImageGridRed(j, i);
                CororGreenTemp(TempSum) = ImageGridGreen(j, i);
                CororBlueTemp(TempSum) = ImageGridBlue(j, i);
                
                TempSum = TempSum+1;

                % Texture Information

                if (j < (x + Step_X / 2) && i < (y + Step_Y / 2))
                    NeighborhoodArea1 = NeighborhoodArea1 + ImageGrid(j, i);
                end
                if (j >= (x + Step_X / 2) && i < (y + Step_Y / 2)) 
                    NeighborhoodArea2 = NeighborhoodArea2 + ImageGrid(j, i);
                end
                if (j < (x + Step_X / 2) && i >= (y + Step_Y / 2)) 
                    NeighborhoodArea3 = NeighborhoodArea3 + ImageGrid(j, i);
                end
                if (j >= (x + Step_X / 2) && i >= (y + Step_Y / 2)) 
                    NeighborhoodArea4 = NeighborhoodArea4 + ImageGrid(j, i);
                end


            end
        end
        
        
        NeighborhoodArea1 = fix(NeighborhoodArea1 * (4.0 / (Step_X * Step_Y)));
        NeighborhoodArea2 = fix(NeighborhoodArea2 * (4.0 / (Step_X * Step_Y)));
        NeighborhoodArea3 = fix(NeighborhoodArea3 * (4.0 / (Step_X * Step_Y)));
        NeighborhoodArea4 = fix(NeighborhoodArea4 * (4.0 / (Step_X * Step_Y)));
        
        Mask1 = abs(NeighborhoodArea1 * 2 + NeighborhoodArea2 * (-2) + NeighborhoodArea3 * (-2) + NeighborhoodArea4 * 2);
        Mask2 = abs(NeighborhoodArea1 * 1 + NeighborhoodArea2 * 1 + NeighborhoodArea3 * (-1) + NeighborhoodArea4 * (-1));
        Mask3 = abs(NeighborhoodArea1 * 1 + NeighborhoodArea2 * (-1) + NeighborhoodArea3 * 1 + NeighborhoodArea4 * (-1));
        Mask4 = abs(NeighborhoodArea1 * sqrt(2) + NeighborhoodArea2 * 0 + NeighborhoodArea3 * 0 + NeighborhoodArea4 * (-sqrt(2)));
        Mask5 = abs(NeighborhoodArea1 * 0 + NeighborhoodArea2 * sqrt(2) + NeighborhoodArea3 * (-sqrt(2)) + NeighborhoodArea4 * 0);
        
        Max = max(Mask1,max(Mask2,max(Mask3,max(Mask4,Mask5))));
        
        Mask1 = Mask1 ./ Max;
        Mask2 = Mask2 ./ Max;
        Mask3 = Mask3 ./ Max;
        Mask4 = Mask4 ./ Max;
        Mask5 = Mask5 ./ Max;
        
        T = 0;
        
        if(Max < T0)
           Edges(1) = 0;
           T = 1;
        else
           T = 0;
           if(Mask1 > T1)
           T=T+1;
           Edges(T) = 1;
           end
           
           if(Mask2 > T2)
           T=T+1;
           Edges(T) = 2;
           end
           
           if(Mask3 > T2)
           T=T+1;
           Edges(T) = 3;
           end
           
           if(Mask4 > T3)
           T=T+1;
           Edges(T) = 4;
           end
           
           if(Mask5 > T3)
           T=T+1;
           Edges(T) = 5;
           end
            
            
        end
            
       
        for i =1:Step_Y * Step_X
           MeanRed = MeanRed + CororRed(i);
           MeanGreen = MeanGreen + CororGreen(i);
           MeanBlue = MeanBlue + CororBlue(i);
        end
        
%         MeanRed = round(MeanRed / (Step_Y * Step_X))/255.0;
%         MeanGreen = round(MeanGreen / (Step_Y * Step_X))/255.0;
%         MeanBlue = round(MeanBlue / (Step_Y * Step_X))/255.0;
        
        MeanRed = fix(MeanRed / (Step_Y * Step_X))/255.0;
        MeanGreen = fix(MeanGreen / (Step_Y * Step_X))/255.0;
        MeanBlue = fix(MeanBlue / (Step_Y * Step_X))/255.0;

        HSV = rgb2hsv([MeanRed MeanGreen MeanBlue]);
        
        HSV(1) = fix(HSV(1) * 360);
        HSV(2) = fix(HSV(2) * 255);
        HSV(3) = fix(HSV(3) * 255);
        
        
        if(Compact == 0)
            Fuzzy10BinResultTable = Fuzzy10Bin(HSV(1), HSV(2), HSV(3), 2); 
            Fuzzy24BinResultTable = Fuzzy24Bin(HSV(1), HSV(2), HSV(3), Fuzzy10BinResultTable, 2); 
            
            for i=1:T
               for j=1:24 
                   if(Fuzzy24BinResultTable(j) > 0)
                      DescriptorVector(24 * Edges(i) + j) = DescriptorVector(24 * Edges(i) + j) + Fuzzy24BinResultTable(j);
                   end
               end
            end
        else
            Fuzzy10BinResultTable = Fuzzy10Bin(HSV(1), HSV(2), HSV(3), 2);
            for i=1:T+1
               for j=1:10
                   if(Fuzzy10BinResultTable(j) > 0)
                      DescriptorVector(10 * Edges(i) + j) = DescriptorVector(10 * Edges(i) + j) + Fuzzy10BinResultTable(j);
                   end
               end
            end           
        end
    end
end

SUM = sum(DescriptorVector);
DescriptorVector(1:144) = DescriptorVector(1:144)/SUM;

DescriptorVector = CEDDQuant(DescriptorVector);

end

function [ histogram ] = Fuzzy10Bin( hue, saturation, value, method )
histogram(1:10) = 0;

HueMembershipValues = [0,0,5, 10,5,10,35,50,35,50,70, 85,70,85,150, 165, 150,165,195, 205,195,205,265, 280,265,280,315, 330, 315,330,360,360];
           
SaturationMembershipValues = [0,0,10, 75,10,75,255,255];

ValueMembershipValues = [0,0,10,75,10,75,180,220,180,220,255,255];

HueActivation(1:8) = 0;
SaturationActivation(1:2) = 0;
ValueActivation(1:3) = 0;


%find membership values 

%Hue
TempHue = 1;
for i=1:4:32
   if(hue >= HueMembershipValues(i+1) && hue <= HueMembershipValues(i+2))
      HueActivation(TempHue) = 1;    
   end
   
   if(hue >= HueMembershipValues(i) && hue < HueMembershipValues(i+1))
      HueActivation(TempHue) = (hue - HueMembershipValues(i)) / (HueMembershipValues(i+1) - HueMembershipValues(i));    
   end
   
    if(hue > HueMembershipValues(i+2) && hue < HueMembershipValues(i+3))
      HueActivation(TempHue) = (hue - HueMembershipValues(i+2)) / (HueMembershipValues(i+2) - HueMembershipValues(i+3)) + 1;    
   end
   
   TempHue = TempHue + 1;
end

%Saturation
TempSaturation = 1;
for i=1:4:8
   if(saturation >= SaturationMembershipValues(i+1) && saturation <= SaturationMembershipValues(i+2))
      SaturationActivation(TempSaturation) = 1;    
   end
   
   if(saturation >= SaturationMembershipValues(i) && saturation < SaturationMembershipValues(i+1))
      SaturationActivation(TempSaturation) = (saturation - SaturationMembershipValues(i)) / (SaturationMembershipValues(i+1) - SaturationMembershipValues(i));    
   end
   
    if(saturation > SaturationMembershipValues(i+2) && saturation < SaturationMembershipValues(i+3))
      SaturationActivation(TempSaturation) = (saturation - SaturationMembershipValues(i+2)) / (SaturationMembershipValues(i+2) - SaturationMembershipValues(i+3)) + 1;    
   end
   
   TempSaturation = TempSaturation + 1;
end

%Value
TempValue = 1;
for i=1:4:12
   if(value >= ValueMembershipValues(i+1) && value <= ValueMembershipValues(i+2))
      ValueActivation(TempValue) = 1;    
   end
   
   if(value >= ValueMembershipValues(i) && value < ValueMembershipValues(i+1))
      ValueActivation(TempValue) = (value - ValueMembershipValues(i)) / (ValueMembershipValues(i+1) - ValueMembershipValues(i));    
   end
   
    if(value > ValueMembershipValues(i+2) && value < ValueMembershipValues(i+3))
      ValueActivation(TempValue) = (value - ValueMembershipValues(i+2)) / (ValueMembershipValues(i+2) - ValueMembershipValues(i+3)) + 1;    
   end
   
   TempValue = TempValue + 1;
end

%method einai panta 2: multiparticipate defazzificator
Fuzzy10BinRulesDefinition = [
                          0,0,0,2                          
                          0,1,0,2
                          0,0,2,0
                          0,0,1,1
                          1,0,0,2                          
                          1,1,0,2
                          1,0,2,0
                          1,0,1,1
                          2,0,0,2                          
                          2,1,0,2
                          2,0,2,0
                          2,0,1,1
                          3,0,0,2                         
                          3,1,0,2
                          3,0,2,0
                          3,0,1,1
                          4,0,0,2                          
                          4,1,0,2
                          4,0,2,0
                          4,0,1,1
                          5,0,0,2                          
                          5,1,0,2
                          5,0,2,0
                          5,0,1,1
                          6,0,0,2                          
                          6,1,0,2
                          6,0,2,0
                          6,0,1,1
                          7,0,0,2                          
                          7,1,0,2
                          7,0,2,0
                          7,0,1,1
                          0,1,1,3
                          0,1,2,3                     
                          1,1,1,4
                          1,1,2,4
                          2,1,1,5
                          2,1,2,5
                          3,1,1,6
                          3,1,2,6
                          4,1,1,7
                          4,1,2,7
                          5,1,1,8
                          5,1,2,8
                          6,1,1,9
                          6,1,2,9
                          7,1,1,3
                          7,1,2,3]; 


if(method == 2) 
    RuleActivation = -1;
    
    for i=1:48
       if((HueActivation(Fuzzy10BinRulesDefinition(i,1)+1)>0) &&(SaturationActivation(Fuzzy10BinRulesDefinition(i,2)+1)>0) && (ValueActivation(Fuzzy10BinRulesDefinition(i,3)+1)>0))
           
           RuleActivation = Fuzzy10BinRulesDefinition(i,4);
           Minimum = 0;
           Minimum = min(HueActivation(Fuzzy10BinRulesDefinition(i,1)+1),min(SaturationActivation(Fuzzy10BinRulesDefinition(i,2)+1),ValueActivation(Fuzzy10BinRulesDefinition(i,3)+1)));
           
           histogram(RuleActivation+1) = histogram(RuleActivation+1) + Minimum;           
       end
    end    
end

end

function [ histogram ] = Fuzzy24Bin( hue, saturation, value, Fuzzy10binHist, method )
histogram(1:24) = 0;

ResultsTable(1:3) = 0;

SaturationMembershipValues = [0 0 68 188 68 188 255 255];
ValueMembershipValues = [0 0 68 188 68 188 255 255];

SaturationActivation(1:2) = 0;
ValueActivation(1:2) = 0;
Temp = 0;

%find membership values 

%Saturation
TempSaturation = 1;
for i=1:4:8
   if(saturation >= SaturationMembershipValues(i+1) && saturation <= SaturationMembershipValues(i+2))
      SaturationActivation(TempSaturation) = 1;    
   end
   
   if(saturation >= SaturationMembershipValues(i) && saturation < SaturationMembershipValues(i+1))
      SaturationActivation(TempSaturation) = (saturation - SaturationMembershipValues(i)) / (SaturationMembershipValues(i+1) - SaturationMembershipValues(i));    
   end
   
    if(saturation > SaturationMembershipValues(i+2) && saturation < SaturationMembershipValues(i+3))
      SaturationActivation(TempSaturation) = (saturation - SaturationMembershipValues(i+2)) / (SaturationMembershipValues(i+2) - SaturationMembershipValues(i+3)) + 1;    
   end
   
   TempSaturation = TempSaturation + 1;
end

%Value
TempValue = 1;
for i=1:4:8
   if(value >= ValueMembershipValues(i+1) && value <= ValueMembershipValues(i+2))
      ValueActivation(TempValue) = 1;    
   end
   
   if(value >= ValueMembershipValues(i) && value < ValueMembershipValues(i+1))
      ValueActivation(TempValue) = (value - ValueMembershipValues(i)) / (ValueMembershipValues(i+1) - ValueMembershipValues(i));    
   end
   
    if(value > ValueMembershipValues(i+2) && value < ValueMembershipValues(i+3))
      ValueActivation(TempValue) = (value - ValueMembershipValues(i+2)) / (ValueMembershipValues(i+2) - ValueMembershipValues(i+3)) + 1;    
   end
   
   TempValue = TempValue + 1;
end

for i=4:10
   Temp = Temp +  Fuzzy10binHist(i); 
end

Fuzzy24BinRulesDefinition =[
                          1,1,1
                          0,0,2                     
                          0,1,0
                          1,0,2];

if(Temp > 0)
    RuleActivation = -1;
    
    for i=1:length(Fuzzy24BinRulesDefinition)
       if((SaturationActivation(Fuzzy24BinRulesDefinition(i,1)+1)>0) && (ValueActivation(Fuzzy24BinRulesDefinition(i,2)+1)>0))
           
           RuleActivation = Fuzzy24BinRulesDefinition(i,3);
           Minimum = 0;
           Minimum = min(SaturationActivation(Fuzzy24BinRulesDefinition(i,1)+1),ValueActivation(Fuzzy24BinRulesDefinition(i,2)+1));
           
           ResultsTable(RuleActivation+1) = ResultsTable(RuleActivation+1) + Minimum;           
       end
    end 
    
end



for i=1:3
   histogram(i) = histogram(i) +  Fuzzy10binHist(i);
end

for i=3:9
    histogram((i-2)*3+1) = histogram((i-2)*3+1) + Fuzzy10binHist(i+1)*ResultsTable(1);
    histogram((i-2)*3+2) = histogram((i-2)*3+2) + Fuzzy10binHist(i+1)*ResultsTable(2);
    histogram((i-2)*3+3) = histogram((i-2)*3+3) + Fuzzy10binHist(i+1)*ResultsTable(3);
    
end


end


function [ FinalCEDD ] = CEDDQuant( CEDDVector )

QuantTable = [180.19686541079636,23730.024499150866,61457.152912541605,113918.55437576842,179122.46400035513,260980.3325940354,341795.93301552488,554729.98648386425];
QuantTable2 = [209.25176965926232, 22490.5872862417345, 60250.8935141849988, 120705.788057580583, 181128.08709063051, 234132.081356900555, 325660.617733105708, 520702.175858657472];
QuantTable3 = [405.4642173212585, 4877.9763319071481, 10882.170090625908, 18167.239081219657, 27043.385568785292, 38129.413201299016, 52675.221316293857, 79555.402607004813];
QuantTable4 = [405.4642173212585, 4877.9763319071481, 10882.170090625908, 18167.239081219657, 27043.385568785292, 38129.413201299016, 52675.221316293857, 79555.402607004813];
QuantTable5 = [968.88475977695578, 10725.159033657819, 24161.205360376698, 41555.917344385321, 62895.628446402261, 93066.271379694881, 136976.13317822068, 262897.86056221306];
QuantTable6 = [968.88475977695578, 10725.159033657819, 24161.205360376698, 41555.917344385321, 62895.628446402261, 93066.271379694881, 136976.13317822068, 262897.86056221306];



FinalCEDD(1:144) = 0;
ElementsDistance(1:8) = 0;

Maximum = 1;

for i=1:14
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

for i=1:24
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

for i=25:48
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable2(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

for i=49:72
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable3(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

for i=73:96
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable4(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

for i=97:120
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable5(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

for i=121:144
    FinalCEDD(i) = 0;
    for j=1:8
        ElementsDistance(j) = abs(CEDDVector(i) - QuantTable6(j)/1000000);    
    end
    Maximum = 1;
    for j=1:8
        if(ElementsDistance(j) < Maximum)
           Maximum = ElementsDistance(j);
           FinalCEDD(i) = j-1;
        end
    end
end

end

