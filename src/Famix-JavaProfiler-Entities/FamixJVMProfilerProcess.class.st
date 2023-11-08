"
I hold the information of what happen when a method was executed in my Java program
"
Class {
	#name : #FamixJVMProfilerProcess,
	#superclass : #FamixJVMProfilerEntity,
	#instVars : [
		'#id => FMProperty',
		'#nbInvocations => FMProperty',
		'#parentProcess => FMOne type: #FamixJVMProfilerProcess opposite: #subProcesses',
		'#profile => FMOne type: #FamixJVMProfilerProfile opposite: #profiling',
		'#rawMthSignature => FMProperty',
		'#relativeOrder => FMProperty',
		'#subProcesses => FMMany type: #FamixJVMProfilerProcess opposite: #parentProcess',
		'#totalTime => FMProperty',
		'#totalTimeCPU => FMProperty'
	],
	#category : #'Famix-JavaProfiler-Entities-Entities'
}

{ #category : #meta }
FamixJVMProfilerProcess class >> annotation [

	<FMClass: #Process super: #FamixJVMProfilerEntity>
	<package: #'Famix-JavaProfiler-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixJVMProfilerProcess >> addSubProcess: anObject [
	<generated>
	^ self subProcesses add: anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> id [

	<FMProperty: #id type: #String>
	<generated>
	^ id
]

{ #category : #accessing }
FamixJVMProfilerProcess >> id: anObject [
	<generated>
	id := anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> nbInvocations [

	<FMProperty: #nbInvocations type: #Number>
	<generated>
	^ nbInvocations
]

{ #category : #accessing }
FamixJVMProfilerProcess >> nbInvocations: anObject [
	<generated>
	nbInvocations := anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> origin [
	"Relation named: #origin type: #FamixTMethod opposite: #JVMProcesses"

	<generated>
	<FMProperty: #origin type: #FamixTMethod opposite: #JVMProcesses>
	^ self attributeAt: #origin ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixJVMProfilerProcess >> origin: anObject [

	<generated>
	self attributeAt: #origin put: (FMMultivalueLink on: self update: #JVMProcesses from: self origin to: anObject).
]

{ #category : #accessing }
FamixJVMProfilerProcess >> parentProcess [
	"Relation named: #parentProcess type: #FamixJVMProfilerProcess opposite: #subProcesses"

	<generated>
	^ parentProcess
]

{ #category : #accessing }
FamixJVMProfilerProcess >> parentProcess: anObject [

	<generated>
	parentProcess := anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> profile [
	"Relation named: #profile type: #FamixJVMProfilerProfile opposite: #profiling"

	<generated>
	<container>
	^ profile
]

{ #category : #accessing }
FamixJVMProfilerProcess >> profile: anObject [

	<generated>
	profile := anObject
]

{ #category : #navigation }
FamixJVMProfilerProcess >> profileGroup [
	<generated>
	<navigation: 'Profile'>
	^ MooseSpecializedGroup with: self profile
]

{ #category : #accessing }
FamixJVMProfilerProcess >> rawMthSignature [

	<FMProperty: #rawMthSignature type: #String>
	<generated>
	^ rawMthSignature
]

{ #category : #accessing }
FamixJVMProfilerProcess >> rawMthSignature: anObject [
	<generated>
	rawMthSignature := anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> relativeOrder [

	<FMProperty: #relativeOrder type: #Number>
	<generated>
	^ relativeOrder
]

{ #category : #accessing }
FamixJVMProfilerProcess >> relativeOrder: anObject [
	<generated>
	relativeOrder := anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> subProcesses [
	"Relation named: #subProcesses type: #FamixJVMProfilerProcess opposite: #parentProcess"

	<generated>
	<derived>
	^ subProcesses
]

{ #category : #accessing }
FamixJVMProfilerProcess >> subProcesses: anObject [

	<generated>
	subProcesses value: anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> totalTime [

	<FMProperty: #totalTime type: #String>
	<generated>
	^ totalTime
]

{ #category : #accessing }
FamixJVMProfilerProcess >> totalTime: anObject [
	<generated>
	totalTime := anObject
]

{ #category : #accessing }
FamixJVMProfilerProcess >> totalTimeCPU [

	<FMProperty: #totalTimeCPU type: #String>
	<generated>
	^ totalTimeCPU
]

{ #category : #accessing }
FamixJVMProfilerProcess >> totalTimeCPU: anObject [
	<generated>
	totalTimeCPU := anObject
]
