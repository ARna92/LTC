%%The code enables to evaluate cash flows associated with a homogeneous portfolio of Long-Term Care (LTC) 
%%insurance contracts, taking into account key sources of risk that may affect the profitability of such products.
%%In our paper, we exploit the demographic technical bases made available by ANIA and linked to the text 
%%"Assicurazioni sulla salute: caratteristiche, modelli attuariali e basi tecniche (P. De Angelis, 
%%Luigi Di Falco – Ed. Il Mulino, 2016). Owners of the volume can request the bases following the instruction 
%%at: https://www.ania.it/servizi/studi-e-rapporti-demografici/


%% Input
prompt1="Insert number of insureds in the portfolio";   
prompt2="Insert the benefit amount";
prompt3="Insert opportunity cost rate";
prompt4="Insert technical rate";
prompt5="Insert transition matrix (healthy state)";
prompt6="Insert transition matrix (ill state)";
prompt7="Insert transition matrix (dead state)";
N=input(prompt1);
B=input(prompt2);
co=input(prompt3);
i=input(prompt4);
PH=input(prompt5);
PI=input(prompt6);
PD=input(prompt7);
%% Single premium evaluation 
v = 1/(1+i);
Pr = zeros(1,T+1);
for t = 1:T 
    Pr(t) = B * v^t .* PI(2,t+1); 
end
SP = sum(Pr);

%% Expected profit/loss E[F_t]
EF = zeros(3,T+1);
EF(:,1) = N * SP;  
for j=1:3 %different scenarios
for t = 1:T %time horizon
    costs = zeros(1,1); 
    costs = costs + N * B * PI(j,t+1); 
    for tau = 0:t-1
        costs = costs + N * B * PI(j,tau+1) * (1+co)^(t-tau);
    end
    EF(j,t+1) = N * SP * (1+co)^t - costs;
end
end

%% Utility construction
prompt8="Insert portfolio transition matrix";
prompt9="Insert risk aversion parameter";
P=input(prompt8);
gamma=input(prompt9);
Ut=NaN(3,T);
wealth=NaN(N+1,T,3);
u=NaN(N+1,T,3);
for j=1:3
    for h = 1:N+1 
   wealth(h,1,j)=N*SP*(1+co)-(h-1)*B;
   if wealth(h,1,j)>0
   u(h,1,j)=(wealth(h,1,j)^(1-gamma))/(1-gamma)*P(h,1,j);
   else
    u(h,1,j)=0; 
   end
    end
    Ut(j,1)=sum(u(:,1,j));
end
for j=1:3
   for t=2:T
   for h = 1:N+1
    wealth(h,t,j)=EF(j,t)*(1+co)-(h-1)*B;
    if wealth(h,t,j)>0
     u(h,t,j)=(wealth(h,t,j)^(1-gamma))/(1-gamma)*P(h,t,j);
     else 
      u(h,t,j)=0;
    end
     Ut(j,t)=sum(u(:,t,j));
    end 
    end  
      
end
%% Risk-adjusted utility construction

prompt10="Insert weighting vector";
prompt11="Insert risk score vector";
VAR=NaN(1,T+1);
w=input(prompt10);
ni=input(prompt11);
mu=w(1).*EF(1,:)+w(2).*EF(2,:)+w(3).*EF(3,:);
for t=1:T+1
    VAR(1,t)=var(EF(:,t),w);
end 
xi=sqrt(VAR(1,:))./mu; 
ht=exp(-xi.*(1-ni));
Utrisk=ht(1,:).*Ut(j,:); 
