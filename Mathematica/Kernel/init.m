(* These are some standard Mathematica definitions I use.
   Be warned: here be dragons of a noob's design! Anything that works is probably
   someone else's, and anything that is broken is probably mine. *)

BeginPackage["thirtythreeforty`"]

(* PlusMinus does not have an intrinsic definition and must be bound.  Similiar
   rules are recommended by the Wolfram manual, but I grabbed these in particular
   from `https://github.com/Tyilo/Mathematica-init.m`. *)
PlusMinus[{a1_, a2_}] := Module[{r},
	r = {a1, -a2};
	If[r[[1]] == r[[2]], r[[1]], r, r]
];
PlusMinus[a_] := PlusMinus[{a, a}];
PlusMinus[{a1_, a2_}, {b1_, b2_}] := Module[{r},
	r = {a1 + b1, a2 - b2};
	If[r[[1]] == r[[2]], r[[1]], r, r]
];
PlusMinus[{a1_, a2_}, b_] := PlusMinus[{a1, a2}, {b, b}];
PlusMinus[a_, {b1_, b2_}] := PlusMinus[{a, a}, {b1, b2}];
PlusMinus[a_, b_] := PlusMinus[{a, a}, {b, b}];

MinusPlus[{a1_, a2_}] := Module[{r},
	r = {-a1, a2};
	If[r[[1]] == r[[2]], r[[1]], r, r]
];
MinusPlus[a_] := MinusPlus[{a, a}];
MinusPlus[{a1_, a2_}, {b1_, b2_}] := Module[{r},
	r = {a1 - b1, a2 + b2};
	If[r[[1]] == r[[2]], r[[1]], r, r]
];
MinusPlus[{a1_, a2_}, b_] := MinusPlus[{a1, a2}, {b, b}];
MinusPlus[a_, {b1_, b2_}] := MinusPlus[{a, a}, {b1, b2}];
MinusPlus[a_, b_] := MinusPlus[{a, a}, {b, b}];

(* Annotate and display a Table as a LabeledGrid *)
LabeledGrid[table_, {x_, y_},
   opts : OptionsPattern[{LabeledGrid, Grid}]] :=
  Module[{doneX, MakeLabel, maxX, maxY, styles, styleSeq},
   styles = OptionValue[LabelStyle];
   styleSeq = If[ListQ[styles],
     Sequence @@ styles,
     Sequence@styles];
   MakeLabel[in_List, dim_] :=
    PadRight[Map[Style[#, styleSeq] &, in], dim, ""];
   MakeLabel[in_Function, dim_] :=
    Table[Style[in[elem], styleSeq], {elem, 1, dim}];
   maxX = Max @@ Length /@ table;
   maxY = Length[table];
   doneX = Prepend[table, MakeLabel[x, maxX]];
   Grid[MapThread[Prepend, {doneX, Join[{""}, MakeLabel[y, maxY]]}],
    opts]
   ];
Options[LabeledGrid] = {LabelStyle -> {}};
LabeledGrid::usage =
  "LabeledGrid[table, {column, row}, LabelStyle \[Rule] {}] adds \
elements from column and row to each corresponding column and row of \
table. Or, if column and row are functions, the labels are created by \
evaluating the function with each row or column index.";

(* Miscellaneous conveniences *)

AverageValue[f_, {x_, a_, b_}] := 1/(b - a) * Integrate[f, {x, a, b}];
AverageValue::usage = "gives the average value of f[x] with respect to x over the interval {a, b}.";
SyntaxInformation[AverageValue] = {"ArgumentsPattern" -> {_, {_, _, _}}, "LocalVariables" -> {"Plot", {2, 2}}};

dB[x_] := 10*Log10[x];
idB[x_] := 10^(x/10);

ToUnit[unit_][x__] := UnitConvert[x, unit];
ToUnit::usage = "ToUnit[unit] represents an operator that converts its operand to unit.  It is most useful as a postfix operand.";
SyntaxInformation[ToUnit] = {"ArgumentsPattern" -> {_}};

(* Functions for Radar and Signals & Systems *)

InstantFreq[f_, t_] := 1/(2 \[Pi]) D[f, t];
InstantFreq::usage = "InstantFreq[f[t], t] gives the instantaneous frequency of f[t] with respect to t";
SyntaxInformation[InstantFreq] = {"ArgumentsPattern" -> {_, _}, "LocalVariables" -> {"D", {2, 2}}};

ListConvolveLikeMATLAB[a_, b_] := ListConvolve[a, b, {1, -1}, 0];
SyntaxInformation[ListConvolveLikeMATLAB] = {"ArgumentsPattern" -> {_, _}};
ListCorrelateLikeMATLAB[a_, b_] := ListCorrelate[a, b, {1, -1}, 0];
SyntaxInformation[ListCorrelateLikeMATLAB] = {"ArgumentsPattern" -> {_, _}};

(* Sometimes you just want the TI-84+ function *)

nPr[n_, r_] := n! / (n - k)!;
nCr[n_, r_] := Binomial[n, r];

EndPackage[]
