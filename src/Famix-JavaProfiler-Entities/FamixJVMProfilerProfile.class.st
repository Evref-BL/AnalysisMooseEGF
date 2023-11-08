"
I hold an entire profile obtain during the execution of a java program
"
Class {
	#name : #FamixJVMProfilerProfile,
	#superclass : #FamixJVMProfilerEntity,
	#instVars : [
		'#id => FMProperty',
		'#name => FMProperty',
		'#profiling => FMMany type: #FamixJVMProfilerProcess opposite: #profile'
	],
	#category : #'Famix-JavaProfiler-Entities-Entities'
}

{ #category : #meta }
FamixJVMProfilerProfile class >> annotation [

	<FMClass: #Profile super: #FamixJVMProfilerEntity>
	<package: #'Famix-JavaProfiler-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixJVMProfilerProfile >> addProfiling: anObject [
	<generated>
	^ self profiling add: anObject
]

{ #category : #accessing }
FamixJVMProfilerProfile >> id [

	<FMProperty: #id type: #String>
	<generated>
	^ id
]

{ #category : #accessing }
FamixJVMProfilerProfile >> id: anObject [
	<generated>
	id := anObject
]

{ #category : #accessing }
FamixJVMProfilerProfile >> name [

	<FMProperty: #name type: #String>
	<generated>
	^ name
]

{ #category : #accessing }
FamixJVMProfilerProfile >> name: anObject [
	<generated>
	name := anObject
]

{ #category : #accessing }
FamixJVMProfilerProfile >> profiling [
	"Relation named: #profiling type: #FamixJVMProfilerProcess opposite: #profile"

	<generated>
	<derived>
	^ profiling
]

{ #category : #accessing }
FamixJVMProfilerProfile >> profiling: anObject [

	<generated>
	profiling value: anObject
]

{ #category : #navigation }
FamixJVMProfilerProfile >> profilingGroup [
	<generated>
	<navigation: 'Profiling'>
	^ MooseSpecializedGroup withAll: self profiling asSet
]
