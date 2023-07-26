# AnalysisMooseEGF
A simple analyser of the legacy backend BL-EGF using Moose and Roassal3 for visualisation. Analyse the endpoint service of the backend by visiting the outgoing method invocation graph

## Installation

	The metacello command to run in a playground, to install your packages.

```smalltalk
Metacello new
  githubUser: 'Evref-BL' project: 'AnalysisMooseEGF' commitish: 'main' path: 'src';
  baseline: 'AnalysisMooseEGF';
  load
```

## Playground example 

  Note that you need to load the eGF Moose model (not provided with this project)

```smalltalk
eGF := EGFEvolAnalysis new.

ucName := 'UcTiersComptableImpl'.
mthName := 'fournirListeTiersComptablesIHM'.

eGFModel := eGF createEGFModelFromUCName: ucName andMethodName: mthName.

"use RSeGFService to access difference Roassal representation, e.g. buildClassDependenciesCanvas and buildInvocationGraphCanvas"
(RSeGFService new eGFInvocationModel: eGFModel; buildClassDependenciesCanvas  ) open.
```

## API 

	Note that this API is a work in progress and will evolve over time. 

