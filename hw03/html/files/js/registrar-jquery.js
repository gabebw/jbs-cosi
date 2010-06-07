/*!
 * registrar-jquery.js
 * Author: Gabe Berke-Williams, 2008
 * Version: 2.7
 * Requires jQuery 1.4.0 or higher for its new recursive $.param.
 * If you really hate jQuery 1.4.0+, you can implement your own $.param that
 * does the same thing and use a lower version of jQuery. This script has only
 * been tested in 1.3.2+.
 *
 * A script to display Brandeis classes in a weekly calendar format. It grabs
 * the data directly from Brandeis.
 */

function registrar(){
    this.Basedir='/~gbw'; // for http://www.people.brandeis.edu/~gbw/, it would be "/~gbw"
    // Only used for permalinks. Not used internally.
    this.fullPathToCallback='http://www.people.brandeis.edu/~gbw/schedule_process_ajax.php?full&';
    // So we don't go crazy if the user whomps on the submit button.
    this.canSubmit = true;
    // timedOutRegex matches what curl returns when it times out.
    this.timedOutRegex = /Operation timed out after .+ milliseconds with .+ bytes received/;
    // Used as class's location when no location is available.
    this.noLocation = 'No classroom provided.';

    this.queryArr = [];
    // Holds numerical course codes (e.g. 400 for "ARBC"). The keys for this.classesByCodenum.
    // Also used to get current position in course pages to parse.
    this.codenums = [];
    // classesByCodenum holds classes like so: 
    //	    400 => ["ARBC 20A sec. 1", "ARBC 30"]
    this.classesByCodenum = {};
    // this.classesToParse and this.parsedClasses are both arrays of classes like "ANTH 163B sec. 1"
    // this.classesToParse is classes that have not yet been added to this.queryArr
    this.classesToParse = [];
    // this.parsedClasses is a list of classes that have been added to this.queryArr
    this.parsedClasses = [];
    // cachedClasses is an object where the keys are term/level combinations
    // like "2009/Fall_UGRD" and the values are arrays of objects where
    // the keys are normalized class names and the values are an array of objects.
    // The size of this array depends on how many different times the class
    // meets (Lecture and Lab -> 2-elem array). Each item in the array is an
    // object with the class data.
    // Example:
    /*
    this.cachedClasses = {
	"2009/Fall_UGRD": {
	    "CHEM 11A 1": [
		{class: "CHEM 11A 1 (Lecture)", time: "10:00 AM-11:00 AM", days: "M,W", location: "gzang"},
		{class: "CHEM 11A 1 (Recitation)", block: "F", location: "also gzang"}
	    ]
	}
    }
    */
    this.cachedClasses = {};
    // Invalid classes, ie "BACON 42c sec. 9"
    this.invalidClasses = [];
    // Classes that aren't offered in the selected term. Displayed after schedule is displayed.
    this.notFoundClasses = [];
    // If the user hits submit button without changing anything, we can compare against this.prevClasses and not do anything either.
    // Holds classes with section ("CHEM 11A 1").
    this.prevClasses = [];
    // For comparing current level ("UGRD") and term ("2009/Fall") with 
    // form input to check for changes, since user may keep inputs but
    // change the term or level.
    this.prevLevel = '';
    this.prevTerm = '';
    this.courseAbbrevMap = {
	AAAS: 100,
	AMST: 200,
	ANTH: 300,
	ARBC: 400,
	BCHM: 500,
	BIOC: 750,
	BIO: 700, /* people are lazy */
	BIOL: 700,
	BISC: 700, /* cross-listed in BIO; not its own subject */
	BIPH: 600,
	BUS: 900,
	CHEM: 1000,
	CHIN: 1100,
	CLAS: 1200,
	CHIS: 1250,
	COML: 1300,
	COEX: 1225,
	COSI: 1400,
	CP: 1450,
	EAS: 1500,
	ECON: 1600,
	ECS: 2000,
	ED: 1700,
	ENG: 1800,
	ENVS: 1900,
	ESL: 1850,
	FA: 2300,
	FILM: 2100,
	FIN: 2200,
	FYS: 8000,
	FREN: 2400,
	FRENCH: 2400, /* some people aren't lazy */
	GER: 2500,
	GS: 2535,
	HBRW: 2800,
	HISP: 6600,
	HIST: 3000,
	HOID: 3100,
	HRNS: 3200,
	HS: 2900,
	HSSP: 2700,
	IIM: 3300,
	IGS: 3400,
	IMES: 3900,
	INET: 3800,
	ITAL: 4000,
	JAPN: 4100,
	JOUR: 4200,
	LING: 4600,
	LALS: 4300,
	LGLS: 4400,
	MATH: 4700,
	MEVL: 4800,
	MUS: 5000,
	NEJS: 5100,
	NEUR: 5200,
	NBIO: 5200,
	NPSY: 5200,
	PAX: 5300,
	PE: 5500,
	PHIL: 5400,
	PHYS: 5600,
	POL: 5700,
	PSYC: 5900,
	QBIO: 5950,
	REES: 6200,
	REL: 6000,
	RUS: 6300,
	SAS: 6550,
	SPAN: 6625,
	SJSP: 6400,
	SOC: 6500,
	THA: 6700,
	USEM: 7025,
	UWS: 7050,
	COMP: 7050,
	WMGS: 6900,
	YDSH: 7000
    };
    // URL shortening variables
    this.urlToShort = {}; // map longUrl -> shortUrl
    this.shortUrlLoadingText = 'Loading shortened URL...';
    this.$shortUrlElem = $('#link');
    // Google analytics tracking
    this.doTracking = true;
}

registrar.prototype.trackEvent = function(){
    if( this.doTracking === false || pageTracker === undefined ){
	return false;
    }
    // category, action, optional_label, optional_value
    if( this.parsedClasses.length > 0 ){
	pageTracker._trackEvent('Registrar Schedule', 'Success', this.parsedClasses.join(', '), this.parsedClasses.length);
    }
    if( this.notFoundClasses.length > 0 ){
	pageTracker._trackEvent('Registrar Schedule', 'Not Found', this.notFoundClasses.join(', '), this.notFoundClasses.length);
    }
};

registrar.prototype.set_status = function(str){
    $('#status').text('Status: ' + str);
};

registrar.prototype.set_error = function(str){
    $('#status').text('Status: ' + str).wrap('<b></b>');
};

registrar.prototype.show_bad = function(){
    var badStr = '',
	invalidStr,
	notFoundStr;
    if( this.invalidClasses.length === 0 &&
	this.notFoundClasses.length === 0 ){
	    this.hide_bad();
    } else {
	if( this.invalidClasses.length > 0 ){
	    invalidStr = '"' + this.invalidClasses.join('", "') + '"';
	    if( this.invalidClasses.length == 1 ){
		badStr += '<p>Invalid class: ' + invalidStr + '</p>';
	    } else {
		badStr += '<p>Invalid classes: ' + invalidStr + '</p>';
	    }
	}
	if( this.notFoundClasses.length > 0 ){
	    notFoundStr = '"' + this.notFoundClasses.join('", "') + '"';
	    if( this.notFoundClasses.length == 1 ){
		badStr += '<p>The following class was not found: ' + notFoundStr + '</p>';
	    } else {
		badStr += '<p>The following classes were not found: ' + notFoundStr + '</p>';
	    }
	}
	$('#bad').html(badStr).show();
    }
};

registrar.prototype.hide_bad = function(){
    $('#bad').hide().empty();
};

registrar.prototype.reset_vars = function(){
    // Reset codenums because otherwise submitting multiple
    // times with the same input just accrues classes.
    this.codenums = [];
    this.queryArr = [];
    // Reset classesByCodenum to avoid having classes be
    // re-added in insert_pages (addClasses) even if
    // we don't have them in the form.
    this.classesByCodenum = {};
    this.classesToParse = [];
    this.parsedClasses = [];
    this.notFoundClasses = [];
    this.invalidClasses = [];
};

registrar.prototype.check_and_submit = function(){
    // We don't set canSubmit to true in this function because if we get here
    // then it means that the program is just checking in, ie the first of two
    // classes was parsed and it wants to know if it can submit.
    // It's still processing, so don't let the user submit again.
    if( this.classesToParse.length != this.parsedClasses.length ){
	return false;
    }
    if( this.classesToParse.sort().join() === this.parsedClasses.sort().join() ){
	// submit_form sets canSubmit = true and runs reset_vars() in onComplete
	this.submit_form('formID');
    }
};

/**
 * Inserts a div with the page for a subject and calls parse_page to extract
 * all requested classes in that subject area. If we have already parsed all
 * pages, submits. 
 * - We pass in codenum instead of looping over this.codenums
 * inside the function because by the time the success() ajax callback is
 * triggered, the loop has moved to the last codenum. Only doing one codenum at
 * a time keeps it static.
 * - Assumes all classes are the same level - pass in ugrad/grad separately
 * Only creates an element once for each term and code, so the id
 * is unique (e.g. 'Fall_2008_5500_UGRD' for 
 * undergraduate PE (5500) in Fall 2008 (Fall_2008))
 */
registrar.prototype.insert_page = function(appendToId, codenum, term, level){
    var that = this,
	// term is like "Fall/2008" so remove the "/" which is invalid in an ID
	searchResultId = term.replace('/', '_') + '_' + codenum + '_' + level,
	$searchResultElem = $('#'+searchResultId),
	position = this.codenums.indexOf(codenum), // used for "Page X of 3"
	addClasses = this.classesByCodenum[codenum],
	elementExists = $searchResultElem.length !== 0,
	elementFetched = (elementExists && ! $searchResultElem.text().match(this.timedOutRegex)), 
	registrarUrl, // the registrar url that we scrape via proxy
	proxyUrl;      // the url for the proxy with registrarUrl passed in via GET

    if( elementExists && elementFetched ){
	// Page is already fetched and sane.
	this.set_status('Already fetched page ' + (position+1) + '.');
	this.parse_page(searchResultId, addClasses);
	this.check_and_submit();
    } else {
	this.set_status('Getting page ' + (position+1) + ' of ' + this.codenums.length + ' (this may take a sec)...');
	if( ! elementFetched ){
	    // Container exists but content not actually fetched. Re-fetch.
	    $searchResultElem.remove();
	}
	registrarUrl = encodeURIComponent('http://www.brandeis.edu/registrar/schedule/classes/'+term+'/'+codenum+'/'+level);
	proxyUrl = this.Basedir+'/proxy?url='+registrarUrl;
	$.ajax({
	    url: proxyUrl,
	    type: 'GET',
	    success: function(data, textStatus){
			   that.set_status('Loaded ' + (position+1) + ' of ' + that.codenums.length + ' pages.');
			   $('<div/>').attr('id', searchResultId).hide().html(data).appendTo('#'+appendToId);
			   that.parse_page(searchResultId, addClasses);
			   that.check_and_submit();
		       },
	    error: function(xhr, errType, exceptionObj){
			   that.set_error('Error: ' + xhr.status + ': ' + xhr.statusText);
		       }
	});
    }
};

/*
 * parse_page parses the element with id _id_ (ie, the ANTH page) and
 * get the location, day, and time for the classes (eg ANTH 163b section 1)
 * in that element specified by $classes.
 * It sets the appropriate variables in this.queryArr.
 * Note that it only parses the classes in _id_. You will have to call
 * it >1 time if you have classes in another id (e.g. a different subject
 * area).
 * $classes is an array with normalized classnames like: "ANTH 163B 1"
 */
registrar.prototype.parse_page = function(id, classes){
    this.set_status('Parsing page for ' + classes.join(', '));
    var that = this,
	timeout = window.setTimeout(function(){ alert('Parsing the page seems to be taking a long time. Try reloading.'); }, 500),
	ci,		// loop counter when iterating over classes
	prevTermAndLevel = this.prevTerm+'_'+this.prevLevel, // We can use this.prevX because it's really the current term/level
	cache,		// this.cachedClasses[ci] (possible cache or undef)
	cci,		// loop counter for each cache array in $cache
	mytr,		// current <tr> in loop over <td>s
	basicClassname, // eg "ENG 1A 1" (no classtype). Used as a key in this.cachedClasses and is also pushed onto this.parsedClasses to later match against this.classesToParse
	mytds,		// <td>s under <tr>
	classname,	// eg. "BIPH 98A sec. 1 (Reading in Biological Physics)"
	teacher,       
	timeAndClasstypeArr, // contains time and classtype for each time
	tci,		// loop counter over timeAndClasstypeArr
	timeAndClasstypeStr, // holds each item when looping over tACArr
	classtypeMatch = false, // holds result of matching against tACstr
	strParts,	// timeAndClasstypeStr split into time and classtype
	timeParts,	// array like:  ["M,W,Th", "9:10", "AM-10:00", "AM"]
	locationStr,
	blockMatch,
	block = null,
	newClassObj, // an object for storing properties before inserting in qSO
	time,
	days,	     // comma-separated string of days the class meets: "M,W,Th"
	classCache = [];   // array (>=1 item) of anon. objects with qSO data

    // First check for already-cached classes.
    // If cachedClasses[prevTermAndLevel] is undefined, we don't
    // have a cache for this at all.
    if(this.cachedClasses[prevTermAndLevel] !== undefined){
	for(ci=0; ci < classes.length; ci++){
	    cache = this.cachedClasses[prevTermAndLevel][classes[ci]];
	    if(cache !== undefined){
		// Already cached, populate queryArr
		this.parsedClasses.push(classes[ci]);
		for(cci=0; cci<cache.length; cci++){
		    this.queryArr.push(cache[cci]);
		}
		// Remove from classes so we don't parse it again
		classes.splice(ci, 1);
	    }
	}
    
	if(classes.length === 0){
	    // All classes were cached
	    window.clearTimeout(timeout);
	    return true;
	}
    }

    // Selecting only <tr>s with a class conveniently leaves out header <tr>s.
    $('#' + id + ' #classes-list tr[class]').each(function(){
	// PHP in proxy removes related courses section so no need to check.
	mytr = $(this);
	basicClassname = mytr.find('a:first').text();
	// Only parse <tr>s if they contain info for a class in _classes_.
	// We also check that.parsedClasses because the registrar page lists
	// the same class multiple times, like "ENG 1A 1" under 
	// "Core Courses for the Creative Writing Major" and also under
	// "Core Courses for the Creative Writing Major", so don't
	// re-parse if we already added it.
	if( classes.indexOf(basicClassname) === -1 ||
	    that.parsedClasses.indexOf(basicClassname) !== -1){
	    // return non-false to skip to next iteration.
	    return true;
	}
	mytds = mytr.find('td');
	// remove extra spaces from course num.
	// "BIPH 98A sec. 1 (Reading in Biological Physics)"
	classname = basicClassname + ' (' + $(mytds[2]).find('strong').text() + ')';
	// Use .text() so we only get the teacher's name, not the link to their
	// page. Getting the full link to their page makes the URL get so long
	// that it's actually cut off, which gives odd errors.
	teacher = $(mytds[5]).text().replace(',', ', ');
	timeAndClasstypeArr = $(mytds[3]).html().split(/<hr>/i);
	// For each time the class meets, add days, time, and location to
	// this.queryArr and the classCache array.
	for(tci=0; tci<timeAndClasstypeArr.length; tci++){
	    // Reset each time
	    block = null;
	    newClassObj = {};
	    timeAndClasstypeStr = timeAndClasstypeArr[tci];
	    // It's important that this includes the <br>, because then it
	    // doesn't mess things up when we split $strParts into $timeParts
	    classtypeMatch = timeAndClasstypeStr.match(/<strong>(.+):<\/strong><br>/);
	    if( classtypeMatch ){
		// remove classtype so it doesn't mess up $timeParts.
		timeAndClasstypeStr = timeAndClasstypeStr.replace(classtypeMatch[0], '');
		classname = classname + ' (' + classtypeMatch[1] + ')';
	    } 
	    // strParts is like: ["Block&nbsp;F", "M,W,Th 1:10 PM-2:00 PM", "Brown Social Science Center115"]
	    // OR: ["M,W,Th 1:10 PM-2:00 PM", "Brown Social Science Center115"]
	    strParts = timeAndClasstypeStr.split('<br>');
	    blockMatch = strParts[0].match(/^Block&nbsp;(.+)/);
	    if( blockMatch ){
		// Use block.
		block = blockMatch[1];
		if( strParts.length == 3 ){
		    // Add a space so it's "Center 109" not "Center109"
		    locationStr = strParts[2].replace(/([a-z])([0-9])/, "$1 $2");
		} else {
		    locationStr = that.noLocation;
		}
	    } else {
		// No block; break up and process the time string.
		timeParts = strParts[0].split(' ');
		if( strParts.length == 2 ){
		    // Add a space so it's "Center 109" not "Center109"
		    locationStr = strParts[1].replace(/([a-z])([0-9])/, "$1 $2");
		} else {
		    // Location is not available
		    locationStr = that.noLocation;
		}
		// Set days and time.
		days = timeParts.shift(); // "M,W,Th"
		// Now timeParts is just:  ["9:10", "AM–10:00", "AM"]
		time = timeParts.join(' ');
	    }
	    newClassObj = { 'class': classname,
			    teacher: teacher,
			    location: locationStr };
	    if( block === null ){
		newClassObj.days = days;
		newClassObj.time = time;
	    } else {
		newClassObj.block = block;
	    }
	    // Add the now-parsed class to the cache and to queryArr
	    classCache.push(newClassObj);
	    that.queryArr.push(newClassObj);
	}
	// We can use this.prevX because it's really the current term/level
	if( ! (prevTermAndLevel in that.cachedClasses) ){
	    that.cachedClasses[prevTermAndLevel] = {};
	}
	that.cachedClasses[prevTermAndLevel][basicClassname] = classCache;
	that.parsedClasses.push(basicClassname);
    });
    // Remove classes that were not found on the page so check_and_submit doesn't fail.
    $.each(classes, function(i, cls){
	if( that.parsedClasses.indexOf(cls) === -1 ){
	    that.notFoundClasses.push(cls);
	    that.classesToParse.splice(that.classesToParse.indexOf(cls), 1);
	}
    });
    window.clearTimeout(timeout);
    this.set_status('Done parsing page for ' + classes.join(' '));
    return true;
};

registrar.prototype.submit_form = function(formID){
    var that = this,
	ajaxData = $.param({classes: this.queryArr}),
	permalink,
	permalinkNoColor; 
    this.set_status('Preparing data...');
    permalink = this.fullPathToCallback + ajaxData;
    permalinkNoColor = permalink + '&setColor=off';
    this.showShortPermalinks(permalink, permalinkNoColor);
    
    this.set_status('Building schedule...');
    $.ajax({
	url: that.Basedir+'/schedule_process_ajax.php',
	data: ajaxData,
	method: 'GET',
	success: function(data, textStatus){
		     that.set_status('Schedule is displayed. :)');
		     $('#schedTable').html( data );
		 },
	error: function(xhr, errType, exceptionObj){
		   that.set_error("There was a problem with the request (code: " + xhr.status + "; type: " + errType+"). Try again.");
	       },
	complete: function(transport, textStatus){
		      that.show_bad();
		      that.trackEvent();
		      that.reset_vars();
		      that.canSubmit = true;
		      if(textStatus!=='error'){
			  $('#schedTable, #link').show();
		      }
		  }
    });
};

registrar.prototype.submit = function(){
    if( this.canSubmit === false ){
	return false;
    } else {
	this.canSubmit = false;
    }
    // Hide it before checking if user has actually changed the input so that it looks like we're doing something.
    $('#schedTable, #link').hide();
    var that = this,
	serialized = $('#formID').serializeArray(),
	currentTerm  = serialized.shift().value, // e.g. "2009/Fall"
	currentLevel = serialized.shift().value, // e.g. "UGRD"
	trimmed, // input text with spacing normalized
	classes, // array of normalized input text
	classParts, // class split up into parts (["ARBC", "20A", "1"])
	subj,      // subject (eg "ARBC")
	coursenum, // course number (eg "20A")
	section,   // section (eg "1")
	klass,     // [subj, coursenum, section].join(' ')
	courseNum, // the numbers assigned to subjects, like ANTH -> 300
	j; // loop counter
    
    classes = $.map(serialized, function(obj, i){
	// trim() conveniently reduces all-space values to empty string
	trimmed = $.trim(obj.value).replace(/\s+/g, ' ');
	// returning null will remove the empty input
	return ((trimmed==='') ? null : trimmed);
    });

    if( classes.length === 0 ){
	this.set_status('You might want to enter some classes. :)');
	// Clear this.prevClasses because otherwise:
	// 1) User inputs "AMST 100A" -> submits
	// 2) Clears the form -> submits (this message and sched is *hidden*!)
	// 3) User puts in "AMST 100A" and gets "No real change" because
	//    this.prevClasses wasn't cleared, even though it looked like it.
	this.prevClasses = [];
	this.hide_bad();
	this.canSubmit = true;
	return true;
    }

    classes = $.map(classes, function(c, i){
	    if( classes.indexOf(c) < i ){
		// Remove duplicate values.
		return null;
	    }
	    // Normalize classes.
	    classParts = c.split(' ');
	    if( classParts.length < 2 ){
		that.invalidClasses.push(c);
		that.show_bad();
		return null; // remove invalid class
	    }
	    // toUpperCase() matches the registrar, which is like "ARBC 10A"
	    subj = classParts.shift().toUpperCase(); // ARBC
	    coursenum = classParts.shift().toUpperCase(); // 10A
	    section = classParts.join(' ').toLowerCase(); // leftover bits
	    if( ! (subj in that.courseAbbrevMap) ){
		// add to invalidClasses before normalizing so user can match to
		// invalid input 
		that.invalidClasses.push([subj,coursenum,section].join(' '));
		return null;
	    }
	    if( section === '' ){
		section = '1';
	    } else {
		// Check section's sanity. Allow "sec. " for backward
		// compatibility.
		if( /^(sec\.?\s*)?[0-9]$/.test(section) ){
		    // Valid section.
		    section = section.replace(/sec\.?\w*/, '');
		} else {
		    section = '1';
		}
	    }
	    klass = [subj, coursenum, section].join(' ');
	    
	    // Add class to codenums, classesByCodenum and classesToParse
	    courseNum = that.courseAbbrevMap[subj];
	    // Check if it's in codenums because otherwise it adds
	    // it each time for a class and so asking for two CHEM courses
	    // means it's in codenums twice, and parse_page gets called twice.
	    if( that.codenums.indexOf(courseNum) === -1 ){
		that.codenums.push(courseNum);
		// If it's not in codenums, it's not in classesByCodenum either
		that.classesByCodenum[courseNum] = [];
	    }
	    if(that.classesToParse.indexOf(klass) === -1 ){
		// We check if klass is already in here because
		// if the user doesn't change anything, then
		// we get here repeatedly without calling submit_form()
		// and running reset_vars().
		that.classesToParse.push(klass);
		that.classesByCodenum[courseNum].push(klass);
	    }
	    return klass;
    });

    if( this.prevClasses.join() === classes.sort().join() &&
	this.prevLevel === currentLevel &&
	this.prevTerm === currentTerm ){
	// Classes didn't change from last time.
	if( this.invalidClasses.length > 0 ){
	    this.show_bad();
	} else {
	    this.hide_bad();
	}
	this.invalidClasses = [];
	this.set_status("No real change in classes. Same schedule is displayed. :)");
	// Keep the canSubmit = true out of the setTimeout or else the app stops letting users submit.
	this.canSubmit = true;
	// Slow down showing the schedule a tiny bit so user sees that something is indeed happening.
	window.setTimeout(function(){
		$('#schedTable, #link').show();
	}, 1);
	return false;
    } 

    if( this.invalidClasses.length > 0 ){
	this.show_bad();
	if( this.classesToParse.length === 0 ){
	    // All classes are invalid.
	    this.reset_vars();
	    this.canSubmit = true;
	    return false;
	}
    }
   
    // Set prevClasses after validation. Set it here,
    // not in check_and_submit, so that it has classes
    // with sections. 
    this.prevClasses = classes.sort();
    this.prevLevel = currentLevel;
    this.prevTerm = currentTerm;
    for(j=0; j<this.codenums.length; j++){
	this.insert_page('hook', this.codenums[j], currentTerm, currentLevel);
    }
};

registrar.prototype.showShortPermalinks = function(permalink, permalinkNoColor){
    var shortLink,
	shortLinkNoColor,
	urlArray = [], // provide an indexed list of shortened URLs
	that = this,
	shortUrl; // bitly's short URL
    // Checking for undefined makes sure that it is in urlToShort AND
    // that we didn't store a failed bitly request
    if( this.urlToShort[permalink] !== undefined ){
	shortLink = this.urlToShort[permalink];
	shortLinkNoColor = this.urlToShort[permalinkNoColor];
	$('#link').html('Permanent/printable link to this schedule: <a href="'+shortLink+'">'+shortLink+'</a> (with color) or <a href="'+shortLinkNoColor+'">'+shortLinkNoColor+'</a> (no color).');
    } else {
	if( permalink in this.urlToShort &&
	    this.urlToShort[permalink] === undefined ){
	    delete this.urlToShort[permalink]; 
	    delete this.urlToShort[permalinkNoColor];
	}
	this.$shortUrlElem.text(this.shortUrlLoadingText);
	$.getJSON(
	    this.Basedir+'/bitly.php?url[]='+encodeURIComponent(permalink)+'&url[]='+encodeURIComponent(permalinkNoColor),
	    function(data, textStatus){
		if( data.errorCode ){
		    $('#link').html('Permanent/printable link to this schedule: <a href="'+permalink+'">permalink</a> (with color) or <a href="'+permalinkNoColor+'">permalink</a> (no color).');
		} else {
		    for( var url in data.results ){
			shortUrl = data.results[url].shortUrl;
			if(shortUrl === undefined ){
			    // bitly isn't working, use the long url
			    shortUrl = url;
			}
			that.urlToShort[url] = shortUrl;
			urlArray.push(shortUrl);
		    }
		    shortLink = urlArray[0];
		    shortLinkNoColor = urlArray[1];
		    $('#link').html('Permanent/printable link to this schedule: <a href="'+shortLink+'">'+shortLink+'</a> (with color) or <a href="'+shortLinkNoColor+'">'+shortLinkNoColor+'</a> (no color).');
		}
	    }
	);
    }
};
