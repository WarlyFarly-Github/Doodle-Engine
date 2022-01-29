package;

import Note.NoteData;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:FunnyNotes;
	var bpm:Float;
	var needsVoices:Bool;
	var voiceList:Array<String>;
	var speed:FunnySpeed;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	var extraNotes:Map<String, Array<SwagSection>>;
}

typedef FunnySpeed =
{
	var ?easy:Float;
	var ?normal:Float;
	var ?hard:Float;
}

typedef FunnyNotes =
{
	var ?easy:Array<SwagSection>;
	var ?normal:Array<SwagSection>;
	var ?hard:Array<SwagSection>;
}

class SongLoad
{
	public static var curDiff:String = 'normal';
	public static var curNotes:Array<SwagSection>;
	public static var songData:SwagSong;

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function getSong(?diff:String):Array<SwagSection>
	{
		if (diff == null)
			diff = SongLoad.curDiff;

		var songShit:Array<SwagSection> = [];

		if (songData != null)
		{
			switch (diff)
			{
				case 'easy':
					songShit = songData.notes.easy;
				case 'normal':
					songShit = songData.notes.normal;
				case 'hard':
					songShit = songData.notes.hard;
			}
		}

		return songShit;
	}

	public static function getSpeed(?diff:String):Float
	{
		if (diff == null)
			diff = SongLoad.curDiff;

		var speedShit:Float = 1;
		switch (diff)
		{
			case 'easy':
				speedShit = songData.speed.easy;
			case 'normal':
				speedShit = songData.speed.normal;
			case 'hard':
				speedShit = songData.speed.hard;
		}

		return speedShit;
	}

	public static function getDefaultSwagSong():SwagSong
	{
		return {
			song: 'Test',
			notes: {easy: [], normal: [], hard: []},
			bpm: 150,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			speed: {easy: 1, normal: 1, hard: 1},
			validScore: false,
			voiceList: ["BF", "BF-pixel"],
			extraNotes: []
		};
	}

	public static function getDefaultNoteData():NoteData
	{
		return {
			strumTime: 0,
			altNote: false,
			sustainLength: 0,
			noteData: 0
		}
	}

	/**
	 *	Casts the an array to NOTE data (for LOADING shit from json usually)
	 */
	public static function castArrayToNoteData(noteStuff:Array<SwagSection>)
	{
		if (noteStuff == null)
			return;

		trace(noteStuff);

		for (sectionIndex => section in noteStuff)
		{
			for (noteIndex => noteDataArray in section.sectionNotes)
			{
				trace(noteDataArray);

				var arrayDipshit:Array<Dynamic> = cast noteDataArray; // crackhead

				trace(arrayDipshit);

				if (arrayDipshit != null) // array isnt null, that means it loaded it as an array and needs to be manually parsed?
				{
					// at this point noteStuff[sectionIndex].sectionNotes[noteIndex] is an array because of the cast from the first line in this function
					// so this line right here turns it back into the NoteData typedef type because of another bastard cast
					noteStuff[sectionIndex].sectionNotes[noteIndex] = cast SongLoad.getDefaultNoteData(); // turn it from an array (because of the cast), back to noteData? yeah that works

					noteStuff[sectionIndex].sectionNotes[noteIndex].strumTime = arrayDipshit[0];
					noteStuff[sectionIndex].sectionNotes[noteIndex].noteData = arrayDipshit[1];
					noteStuff[sectionIndex].sectionNotes[noteIndex].sustainLength = arrayDipshit[2];
					noteStuff[sectionIndex].sectionNotes[noteIndex].altNote = arrayDipshit[3];
				}
				else if (noteDataArray != null)
				{
					// array is NULL, so it checks if noteDataArray (doesnt exactly NEED to be an 'array' is also null or not.)
					// At this point it should be an OBJECT that can be easily casted!!!

					noteStuff[sectionIndex].sectionNotes[noteIndex] = cast noteDataArray;
				}
				else
					throw "shit brokey"; // i actually dont know how throw works lol
			}
		}
	}

	/**
	 * Cast notedata to ARRAY (usually used for level SAVING)
	 */
	public static function castNoteDataToArray(noteStuff:Array<SwagSection>)
	{
		if (noteStuff == null)
			return;

		for (sectionIndex => section in noteStuff)
		{
			for (noteIndex => noteTypeDefShit in section.sectionNotes)
			{
				var dipshitArray:Array<Dynamic> = [
					noteTypeDefShit.strumTime,
					noteTypeDefShit.noteData,
					noteTypeDefShit.sustainLength,
					noteTypeDefShit.altNote
				];

				noteStuff[sectionIndex].sectionNotes[noteIndex] = cast dipshitArray;
			}
		}
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;

		for (diff in Reflect.fields(Json.parse(rawJson).song.notes))
		{
			switch (diff)
			{
				case "easy":
					castArrayToNoteData(swagShit.notes.hard);

				case "normal":
					castArrayToNoteData(swagShit.notes.normal);
				case "hard":
					castArrayToNoteData(swagShit.notes.hard);
			}
			trace(diff);
		}

		swagShit.validScore = true;

		trace("SONG SHIT ABOUTTA WEEK AGOOO");
		for (field in Reflect.fields(Json.parse(rawJson).song.speed))
		{
			// swagShit.speed[field] = Reflect.field(Json.parse(rawJson).song.speed, field);
			// swagShit.notes[field] = Reflect.field(Json.parse(rawJson).song.notes, field);
			// trace(swagShit.notes[field]);
		}

		// swagShit.notes = cast Json.parse(rawJson).song.notes[SongLoad.curDiff]; // by default uses

		trace('THAT SHIT WAS JUST THE NORMAL NOTES!!!');
		songData = swagShit;
		// curNotes = songData.notes.get('normal');

		return swagShit;
	}
}