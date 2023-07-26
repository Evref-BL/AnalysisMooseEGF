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
		'invocationGraphCache',
		'methodInvokedCache'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #script }
EGFEvolAnalysis >> OldComputeInvocationGraphOfUc: ucName andMethods: mthName withCache: withCache [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	<script>
	| evol ucs seen res block meth |
	self
		deprecated:
		'Use #computeInvocationGraphOfUc:andMethods:withCache: instead'
		on: '26 July 2023'
		in:
		'Pharo-10.0.0+build.538.sha.179ef655ae2b150009a860b127aa3605366659ca (64 Bit)'.
	evol := MooseModel root at: 1.
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].
	seen := Dictionary new.
	res := Dictionary new.
	block := [ :m :outgoing | 
	         m queryAllOutgoing select: #isInvocation thenDo: [ :i | 
		         | method |
		         method := i candidates anyOne.
		         method isStub ifFalse: [ 
			         seen
				         at: method
				         ifPresent: [ :out | outgoing at: method put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: method put: recurOut.
					         seen at: method put: recurOut.
					         block value: method value: recurOut ] ] ].
	         outgoing ].
	meth := (ucs detect: [ :uc | uc name = ucName ]) methods detect: [ :m | 
		        m name = mthName ].
	res at: meth put: (block value: meth value: Dictionary new).

	withCache ifTrue: [ 
		invocationGraphCache at: ucName , mthName put: res ].

	^ res
]

{ #category : #script }
EGFEvolAnalysis >> analysis [

	<script>
	
	| evol ucs seen res block meth |
	evol := MooseModel root at: 1.
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].
	seen := Dictionary new.
	res := Dictionary new.
	block := [ :m :outgoing | 
	         m queryAllOutgoing select: #isInvocation thenDo: [ :i | 
		         | method |
		         method := i candidates anyOne.
		         method isStub ifFalse: [ 
			         seen
				         at: method
				         ifPresent: [ :out | outgoing at: method put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: method put: recurOut.
					         seen at: method put: recurOut.
					         block value: method value: recurOut ] ] ].
	         outgoing ].
	meth := (ucs detect: [ :uc | uc name = 'UcTiersComptableImpl' ])
		        methods detect: [ :m | 
		        m name = 'fournirListeTiersComptablesIHM' ].
	res at: meth put: (block value: meth value: Dictionary new).
	^ res
]

{ #category : #script }
EGFEvolAnalysis >> computeInvocationGraphOfUc: ucName andMethodName: mthName withCache: withCache [

	"ucName := 'UcTiersComptableImpl'.
	mthName := 'fournirListeTiersComptablesIHM'."

	<script>
	| evol ucs visitedMethods res block meth |
	evol := MooseModel root at: 1.
	"get all class that is an UCs in eGF"
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].

	visitedMethods := Dictionary new.
	res := Dictionary new.

	"recursive visiting block"
	block := [ :method :outgoing | "look throught all outgoing entities of m and search the invocation m makes"
	         method queryAllOutgoing
		         select: #isInvocation
		         thenDo: [ :invocation | 
			         | methodInvoc |
			         "select any candidate method that could be the receiver candidat of m"
			         methodInvoc := invocation candidates anyOne.

			         "if the invoked method is not a stub"
			         methodInvoc isStub ifFalse: [ "check if this methodInvoc not stub as already been seen"
				         visitedMethods
					         at: methodInvoc
					         ifPresent: [ :out | outgoing at: methodInvoc put: out ]
					         ifAbsent: [ 
						         | recurOut |
						         recurOut := Dictionary new.
						         outgoing at: methodInvoc put: recurOut.
						         visitedMethods at: methodInvoc put: recurOut.
						         block value: methodInvoc value: recurOut ] ] ].
	         outgoing ].

	"get methods of the UC named from parameters that are named named also from parameters"
	meth := (ucs detect: [ :uc | uc name = ucName ]) methods detect: [ :m | 
		        m name = mthName ].


	"recursivly explore the methods invocations graph"
	res at: meth put: (block value: meth value: Dictionary new).

	

	withCache ifTrue: [ 
		invocationGraphCache at: ucName , mthName put: res.

		methodInvokedCache at: ucName , mthName put: (self flattenInvocationGraph: res) ].

	^ self
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> createEGFModelFromUCName: UCname andMethodName: methodName [

	"create a instance of eGFModelInvocation"

	| model invocGraph methodSet |
	model := EGFInvocationModel new.

	invocationGraphCache at: UCname , methodName ifAbsent: [ 
		self
			computeInvocationGraphOfUc: UCname
			andMethodName: methodName
			withCache: true ].

	invocGraph := invocationGraphCache at: UCname , methodName.
	methodSet := methodInvokedCache at: UCname , methodName.

	model initFromInvocationGraph: invocGraph andMethod: methodSet.
	^ model
]

{ #category : #'as yet unclassified' }
EGFEvolAnalysis >> flattenInvocationGraph: invocationGraph [

	"retrieve the invocation methods graph as a flatten dictionary"

	| recBlock seen entryPoint |
	seen := Dictionary new.

	entryPoint := invocationGraph keys first.

	seen at: entryPoint ifAbsent: [ 
		seen
			at: entryPoint
			put: (invocationGraph at: entryPoint) keys asOrderedCollection ].

	recBlock := [ :method | "explore next invocation"
	            method keysDo: [ :key | 
		            seen at: key ifAbsent: [ 
			            seen
				            at: key
				            put: (method at: key) keys asOrderedCollection.

			            recBlock value: (method at: key) ] ] ].

	invocationGraph valuesDo: [ :dicInvo | 
		dicInvo keysDo: [ :key | 
			seen
				at: key
				ifAbsent: [ 
				seen at: key put: (dicInvo at: key) keys asOrderedCollection ].
			recBlock value: (dicInvo at: key) ] ].



	^ seen
]

{ #category : #initialization }
EGFEvolAnalysis >> initialize [

	invocationGraphCache := Dictionary new.
	methodInvokedCache := Dictionary new.
]

{ #category : #script }
EGFEvolAnalysis >> invocationGraphOfUc: ucName andMethodName: mthName [

	invocationGraphCache
		at: ucName , mthName
		ifPresent: [ invocationGraphCache at: ucName , mthName ]
		ifAbsent: [ 
			 self
				  computeInvocationGraphOfUc: ucName
				  andMethodName: mthName
				  withCache: true ]
]

{ #category : #script }
EGFEvolAnalysis >> invocationGraphOfUcTiersComptableImplWithFournirListeTiersComptablesIHM [

	<script>
	| evol ucs seen res block meth |
	evol := MooseModel root at: 1.
	ucs := evol allClasses select: [ :c | 
		       (c name beginsWith: 'uc' caseSensitive: false) and: [ 
			       c name endsWith: 'impl' caseSensitive: false ] ].
	seen := Dictionary new.
	res := Dictionary new.
	block := [ :m :outgoing | 
	         m queryAllOutgoing select: #isInvocation thenDo: [ :i | 
		         | method |
		         method := i candidates anyOne.
		         method isStub ifFalse: [ 
			         seen
				         at: method
				         ifPresent: [ :out | outgoing at: method put: out ]
				         ifAbsent: [ 
					         | recurOut |
					         recurOut := Dictionary new.
					         outgoing at: method put: recurOut.
					         seen at: method put: recurOut.
					         block value: method value: recurOut ] ] ].
	         outgoing ].
	meth := (ucs detect: [ :uc | uc name = 'UcTiersComptableImpl' ])
		        methods detect: [ :m | 
		        m name = 'fournirListeTiersComptablesIHM' ].
	res at: meth put: (block value: meth value: Dictionary new).
	^ res
]

{ #category : #initialization }
EGFEvolAnalysis >> resetCache [

	invocationGraphCache := Dictionary new
]
