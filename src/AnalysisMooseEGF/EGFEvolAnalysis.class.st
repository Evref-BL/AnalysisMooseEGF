"
Ready to use Playground code : 

eGF := EGFEvolAnalysis new.

ucName := 'UcTiersComptableImpl'.
mthName := 'fournirListeTiersComptablesIHM'.

eGFModel := eGF createEGFModelFromUCName: ucName andMethodName: mthName.

""use RSeGFService to access difference Roassal representation, e.g. buildClassDependenciesCanvas and buildInvocationGraphCanvas""
(RSeGFService new eGFInvocationModel: eGFModel; buildClassDependenciesCanvas  ) open.

"
Class {
	#name : #EGFEvolAnalysis,
	#superclass : #Object,
	#instVars : [
		'modelCache',
		'callflowCache'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
EGFEvolAnalysis class >> loadAllUcImpl [

	| egf ucs |
	egf := self new.
	ucs := egf retrieveAllServiceEndpoints reject: [ :assoc | 
		       assoc value name = 'create' ].
	ucs do: [ :assoc | "stock results in cache"
		egf
			callflowModelFromUCName: assoc key name
			andMethodName: assoc value name ].
	^ egf 	
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis class >> loadRandomUcImpl: aNumber [

	| egf ucs |
	egf := self new.
	ucs := egf retrieveAllServiceEndpoints reject: [ :assoc | 
		       assoc value name = 'create' ].
	1 halt.
	ucs do: [ :assoc | "stock results in cache"
		egf
			callflowModelFromUCName: assoc key name
			andMethodName: assoc value name ].
	^ egf
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis class >> loadTenFirstUcImpl [

	| egf ucs |
	egf := self new.
	ucs := egf retrieveAllServiceEndpoints reject: [ :assoc | 
		       assoc value name = 'create' ].

	ucs from: 1 to: 10 do: [ :assoc | "stock results in cache"
		egf
			callflowModelFromUCName: assoc key name
			andMethodName: assoc value name ].
	^ egf
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> allCallflowModelFromEndpoints: endpoints [

	^ endpoints collect:  [ :assoc | "stock results in cache"
		self
			callflowModelFromUCName: assoc key name
			andMethodName: assoc value name ].
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> allInvockedMethodsOf: aMethod [
	


	^ (aMethod queryAllOutgoing select: #isInvocation)
		  asOrderedCollection select: [ :invocation | 
		  | methodInvoc |
		  "select any candidate method that could be the receiver candidat of m"
		  methodInvoc := invocation candidates anyOne.

		  "if the invoked method is not a stub"
		  methodInvoc isStub = false ]
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> callflowModelFromUCName: UCname andMethodName: methodName [

	"create a instance of eGFModelInvocation"

	| methodSet entryPoint keyName|
	keyName := (self uc: UCname endpoint: methodName).
	callflowCache at: keyName ifAbsent: [ 
		self
			computeCallflowOfUc: UCname
			andMethodName: methodName
			withCache: true ].

	methodSet := (callflowCache at: keyName) value.
	entryPoint := (callflowCache at: keyName) key.


	^ modelCache at: keyName ifAbsentPut: [ 
		  self
			  computeCallflowModelWithMethods: methodSet
			  andAnEntryPoint: entryPoint ]
]

{ #category : #'instance creation' }
EGFEvolAnalysis >> computeCallflowFromMethod: aMethod [

	"retrieve the invocation methods graph as a flatten dictionary"

	| recBlock seen |
	seen := Dictionary new.


	recBlock := [ :method | "explore next invocation"
	            seen at: method ifAbsent: [ 
		            seen
			            at: method
			            put: (self orderByPositionAMethodInvocations: method).
		            (seen at: method) do: [ :child | recBlock value: child ] ] ].



	recBlock value: aMethod.


	^ seen
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> computeCallflowModelWithMethods: methodSet andAnEntryPoint: entryPoint [

	| model |
	model := EGFCallflowModel new.
	^ model initFromMethods: methodSet andAnEntryPoint: entryPoint
]

{ #category : #script }
EGFEvolAnalysis >> computeCallflowOfUc: ucName andMethodName: mthName withCache: withCache [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	<script>
	| evol ucs res meth |
	evol := MooseModel root at: 1.
	"get all class that is an UCs in eGF"
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].

	res := Dictionary new.


	"get methods of the UC named from parameters that are named named also from parameters"
	meth := (ucs detect: [ :uc | uc name = ucName ]) methods detect: [ :m | 
		        m name = mthName ].

	res := self computeCallflowFromMethod: meth.

	withCache ifTrue: [ 
		callflowCache at: (self uc:ucName endpoint: mthName) put: meth -> res ].

	^ self
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> endpointNameFirstWords [

	"return a dictionary of all the first word use in endpoint name. For instance :  'chargerSessionMEXTechnique' return 'charger'
	The returned dictionnary also contains the number of occurences by word : charger -> 733"

	| names |
	names := Dictionary new.

	(self retrieveAllServiceEndpoints reject: [ :assoc | 
		 assoc value name = 'create' ]) do: [ :entry | 
		| str |
		str := entry value name
			       copyFrom: 1
			       to: (entry value name findFirst: [ :c | c isUppercase ]).
		str isNotEmpty ifTrue: [ str := str copyFrom: 1 to: str size - 1 ].

		names
			at: str
			ifPresent: [ names at: str put: (names at: str) + 1 ]
			ifAbsentPut: [ 1 ] ].

	^ names
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> filterEndpointsBeginsWith: aString [

	^ callflowCache associations select: [ :assoc | 
		assoc value key name beginsWith: aString ]
]

{ #category : #initialization }
EGFEvolAnalysis >> initialize [

	modelCache := Dictionary new.
	callflowCache := Dictionary new.
]

{ #category : #inspector }
EGFEvolAnalysis >> inspectionEGFvolAnalyzer [

	<inspectorPresentationOrder: 1 title: 'EGFevo Services'>
	| presenter classNameCompare methodCountSorter |
	classNameCompare := [ :c1 :c2 | c1 name < c2 name ].
	methodCountSorter := [ :c1 :c2 | 
	                     c1 value value size threeWayCompareTo:
		                     c2 value value size ].

	presenter := SpTablePresenter new
		             addColumn: (((SpStringTableColumn
				               title: 'Endpoints'
				               evaluated: [ :assoc | assoc value key name ]) compareFunction: classNameCompare)
				              width: 30;
				              yourself);
		             addColumn: ((SpStringTableColumn
				               title: 'Methods'
				               evaluated: [ :assoc | assoc value value size ]) 
				              sortFunction: methodCountSorter);
		             items: callflowCache associations;
		             beResizable;
		             yourself.
	^ presenter
]

{ #category : #inspector }
EGFEvolAnalysis >> inspectionEGFvolAnalyzerContext: aContext [

	^ aContext active: callflowCache isNotEmpty.
]

{ #category : #testing }
EGFEvolAnalysis >> isThrowingRemoteException: aFamixMethod [

	| execeptions |
	execeptions := aFamixMethod declaredExceptions select: [ :exec | 
		               exec name = #RemoteException ].
	^ execeptions isNotEmpty 
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> orderByPositionAMethodInvocations: aMethod [

	| invocations positions |
	

	"self allInvockedMethodsOf: aMethod "
	
	positions := (self allInvockedMethodsOf: aMethod )
		             collect: [ :invoc | 
			             | mth endpos |
			             mth := invoc candidates anyOne.
			             endpos := invoc sourceAnchor endPos.
			             mth -> endpos ].
	invocations := Dictionary new.
	positions do: [ :assoc | 
		invocations
			at: assoc key
			ifPresent: [ :oldVal | 
				oldVal > assoc value ifTrue: [ 
					invocations at: assoc key put: assoc value ] ]
			ifAbsent: [ invocations at: assoc key put: assoc value ] ].

	^ (invocations associations sort: [ :a1 :a2 | a1 value < a2 value ]) 
		  collect: [ :e | e key ]
]

{ #category : #initialization }
EGFEvolAnalysis >> resetCaches [

	modelCache := Dictionary new.
	callflowCache := Dictionary new
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> retrieveAllServiceEndpoints [

	| endpoints |
	endpoints := OrderedCollection new.

	self searchForUCs do: [ :ucClass | 
		| methods |
		methods := ucClass methods.
		((methods select: [ :m | self isThrowingRemoteException: m ]) 
			 reject: [ :m | m isConstructor ]) do: [ :m | 
			endpoints add: ucClass -> m ] ].

	^ endpoints
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> searchForUCs [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	| evol ucs |
	evol := MooseModel root at: 1.
	"get all class that is an UCs in eGF"
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].

	^ ucs
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> servicesModel [

	"retrieve all the model already in cache"

	^ EGFServicesModel initFrom: modelCache
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> uc: aName endpoint: aMethodName [

	^ aName , '>>' , aMethodName
]
