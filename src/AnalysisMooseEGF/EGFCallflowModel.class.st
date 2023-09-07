Class {
	#name : #EGFCallflowModel,
	#superclass : #Object,
	#instVars : [
		'invocationGraph',
		'classGroup',
		'classDependencies',
		'flattenMethods',
		'entryPoint'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'instance creation' }
EGFCallflowModel class >> newFrom: invocationGraph [

	| invocModel |
	invocModel := EGFCallflowModel new.
	 invocModel initFrom:
		              invocationGraph.
	^ invocModel
]

{ #category : #accessing }
EGFCallflowModel >> classDependencies [
	^ classDependencies
]

{ #category : #setter }
EGFCallflowModel >> classDependencies: aCollection [ 
	classDependencies := aCollection
]

{ #category : #accessing }
EGFCallflowModel >> classGroup [
	^ classGroup
]

{ #category : #setter }
EGFCallflowModel >> classGroup: aCollection [

	classGroup := aCollection.
	"aCollection keys do: [ :key | 
		self classGroup add:
			(EGFClassModel initFrom: key and: (aCollection at: key)) ]"
]

{ #category : #compute }
EGFCallflowModel >> computeClassDependenciesV2From: methods [

	"from a invocationGraph based on the methods, outputs the class dependencies of these methods. 
	from A,B two classes and mA, mB two methods,
	if A:mA() invokes B:mB() then the their is a class dependencies from A to B.	
	"

	| seen classDeps |
	seen := Dictionary new.
	classDeps := Dictionary new.

	methods keysDo: [ :mth | 
		| class |
		class := mth parentType.

		classDeps
			at: class
			ifPresent: [ :val | 
				val addAll: ((methods at: mth) collect: [ :dep | dep parentType ]) ]
			ifAbsent: [ 
				classDeps
					at: class
					put: ((methods at: mth) collect: [ :dep | dep parentType ]) asSet ] ].


	^ classDeps
]

{ #category : #compute }
EGFCallflowModel >> computeClassGroupV2From: methods [

	"return a dictionnary where the class are the keys and their methods are the values "

	| seen seenClasses |
	seen := Dictionary new.
	seenClasses := Dictionary new.



	methods keysDo: [ :meth | 
		| class |
		class := meth parentType.

		seenClasses
			at: class
			ifPresent: [ :v | v add: meth ]
			ifAbsent: [ seenClasses at: class put: (Set newFrom: { meth }) ] ].
		
		seenClasses associations do:  [ :assoc |
			seenClasses at: assoc key put: ((assoc value) asOrderedCollection) . 
			
			 ].

	^ seenClasses
]

{ #category : #accessing }
EGFCallflowModel >> entryPoint [

	^ entryPoint
]

{ #category : #accessing }
EGFCallflowModel >> entryPoint: aFamixJavaMethod [

	entryPoint := aFamixJavaMethod
]

{ #category : #'as yet unclassified' }
EGFCallflowModel >> exportCSV [

	| export |
	export := String new.
	export := export , 'Class name, Method name, Complexity cyclo, LoC'
	          , String cr.
	flattenMethods associations do: [ :assoc | 
		| meth |
		meth := assoc key.

		export := export
		          ,
		          (meth parentType mooseName replaceAllRegex: ',' with: '_')
		          , ',' , (meth signature replaceAllRegex: ',' with: '_')
		          , ',' , meth cyclomaticComplexity printString , ','
		          , meth sourceText lines size printString , String cr ].
	^ export
]

{ #category : #'as yet unclassified' }
EGFCallflowModel >> exportComplexityCycloDiagramCSV [

	"export in CSV format a table of all methods with their respective cyclomatic Complexity. Sort the methods in respect of the invocation order."

	| export buildCsv recBlock seen safeGuard |
	export := 'method name, cycloComplexity' , String cr.
	safeGuard := 0.
	seen := Dictionary new.

	buildCsv := [ :method | 
	            export := export
	                      ,
	                      (method signature
		                       replaceAllRegex: ','
		                       with: '_') , ','
	                      , method cyclomaticComplexity printString
	                      , String cr ].


	recBlock := [ :mth | 
	            safeGuard > 100000 ifTrue: [ ^ export ] ifFalse: [safeGuard := safeGuard + 1].
	            seen at: mth ifAbsent: [ 
		            seen at: mth put: true.
		            (flattenMethods at: mth) do: [ :invoc | 
			            buildCsv value: invoc.
			            (flattenMethods at: invoc) do: [ :mthChild | 
				            recBlock value: mthChild ] ] ] ].

	buildCsv value: entryPoint.



	recBlock value: entryPoint.

	^ export
]

{ #category : #accessing }
EGFCallflowModel >> flattenMethods [
	^ flattenMethods
]

{ #category : #'computing - dependencies' }
EGFCallflowModel >> hasDependenciesWith: anEGFCallflowModel [ 
	
	
	^ (self flattenMethods keys intersection: (anEGFCallflowModel flattenMethods keys)) size > 0
]

{ #category : #intialization }
EGFCallflowModel >> initFrom: graph [

	self
		deprecated: 'Use #initFromInvocationGraph:andMethod: instead'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	classGroup := Set new.
	classDependencies := Dictionary new.
	fmx2eGFMethods := Dictionary new.


	self root: graph keys first.
	self invocationGraph: graph.
	self convertToEGFModel: graph.
	self methodFlow: (self computeMethodsSetFrom: graph).
	self classGroup: (self computeClassGroupFrom: graph).

	self classDependencies: (self computeClassDependenciesFrom: graph)
]

{ #category : #intialization }
EGFCallflowModel >> initFromInvocationGraph: aGraph andMethod: methods [

	self
		deprecated: 'Use #initFromMethods:andAnEntryPoint: instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	classGroup := Set new.
	classDependencies := Dictionary new.

	self entryPoint: aGraph keys first.
	self invocationGraph: aGraph.

	flattenMethods := methods.


	self classGroup: (self computeClassGroupV2From: methods).
	self classDependencies:
		(self computeClassDependenciesV2From: methods)
]

{ #category : #intialization }
EGFCallflowModel >> initFromMethods: methods andAnEntryPoint: aMethod [

	classGroup := Set new.
	classDependencies := Dictionary new.

	self entryPoint: aMethod.

	flattenMethods := methods.

	self classGroup: (self computeClassGroupV2From: methods).
	self classDependencies:
		(self computeClassDependenciesV2From: methods)
]

{ #category : #intialization }
EGFCallflowModel >> initialize [

	classGroup := Set new.
	classDependencies := Dictionary new.
	flattenMethods := Dictionary new.

]

{ #category : #inspector }
EGFCallflowModel >> inspectionEGFvolAnalyzer [

	<inspectorPresentationOrder: 1 title: 'Word occurrences'>
	| canvas shapes |
	
	canvas := (RSeGFCallflow new model: self; buildClassDependenciesCanvas ).
	
	^ canvas asPresenter
]

{ #category : #accessing }
EGFCallflowModel >> invocationGraph [

	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	^ invocationGraph
]

{ #category : #setter }
EGFCallflowModel >> invocationGraph: aCollection [

	self
		deprecated: 'Use #nothing instead'
		on: '27 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.

	invocationGraph := aCollection
]

{ #category : #accessing }
EGFCallflowModel >> methods [

	^ self flattenMethods
]