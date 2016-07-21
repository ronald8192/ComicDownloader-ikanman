#!/usr/bin/node

var jsdom = require("jsdom");
var CryptoJS = require("crypto-js");
var request = require('request');
var fs = require('fs');
var opencc = require('node-opencc');

var comicId = undefined;
var chapters = [];

var linksDone = 0;
var getChapterImagesLink = function(chapterLink, displayText, index){
    var mChapterLink = chapterLink.replace("www","m");

    jsdom.env(
        chapterLink,
        ["https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"],
        function (err, window) {
            var $ = window.$;

            //cInfo comes from here
            eval(($("html").html().replace(/(<|>)/g,"\r\n").split("\r\n").map(function(line){return line.indexOf("eval(")>-1?line:''}).compact()[0]));
            // console.log(cInfo);

            chapters[index] = {
                host: "http://i.hamreus.com:8080",
                path: cInfo.path.split("/").map(function(p){return encodeURI(p)}).join("/"),
                displayText: displayText,
                dest: displayText + "|" + cInfo.path.split("/")[cInfo.path.split("/").length-2],
                referer: mChapterLink,
                images : cInfo.files
            };

            if(++linksDone == chapters.length){
                chapters.reverse();
                
                try{
                    fs.accessSync("./download/", fs.F_OK);
                }catch (e){
                    fs.mkdirSync("./download/");
                }
                fs.writeFile("./download/chapters.json", JSON.stringify({
                    comicId: comicId,
                    chapters: chapters
                }), function (err) {
                    if (err) {
                        return console.log(err);
                    }
                    console.log("List of chapters was saved to ./download/chapters.json !");
                });

                // request({
                //     uri: '',
                //     har: {
                //         headers: [
                //             {
                //                 name: 'Referer',
                //                 value: ''
                //             },
                //             {
                //                 name: 'User-Agent',
                //                 value: randomUA()
                //             }
                //         ]
                //     }
                // }).pipe(fs.createWriteStream("./download/a.jpg"))
            }

        }
    );
};


var getChapterLink = function(comicId){
    console.log("Getting list of chapters...");
    jsdom.env(
        "http://www.ikanman.com/support/chapters.aspx?id="+comicId+"&m=1",
        ["https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"],
        function (err, window) {
            var $ = window.$;
            var linksElement = $("a");
            // var links = new Array(linksElement.length);
            chapters = new Array(linksElement.length);
            var translateDone = 0;

            console.log(linksElement.length + " chapters");
            console.log("Translating and getting image links...");
            $.each(linksElement,function(k, v){
                (function (href, displayText, index) {
                    opencc.simplifiedToHongKong(displayText).then(function (result) {
                        if (++translateDone == linksElement.length) console.log("Translate complete.");
                        getChapterImagesLink("http://www.ikanman.com" + href, result, index);
                    });

                })($(v).attr("href"), $(v).find("b").first().html(), k);

            });
        }
    );
};

if (isNaN(parseInt(comicId)) || comicId == undefined || comicId == null) {
    comicId = parseInt(process.argv[2]);
}
if (isNaN(comicId)) throw new Error("Please provide comic ID: `npm start 123` or `node main.js 123`");
getChapterLink(comicId);



var decryptDES = function decryptDES(t){var a=CryptoJS.DES.decrypt({ciphertext:CryptoJS.enc.Base64.parse(t.substring(8))},CryptoJS.enc.Utf8.parse(t.substring(0,8)),{mode:CryptoJS.mode.ECB,padding:CryptoJS.pad.Pkcs7});return a.toString(CryptoJS.enc.Utf8)};

Array.prototype.compact = function() {
    for (var i = 0; i < this.length; i++) {
        if (this[i] === '' || this[i] === undefined || this[i] === null) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
};
