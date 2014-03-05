var context = new webkitAudioContext();
var gainNode = context.createGainNode();
var freqData;
var source;    //マイクの入力
var analyserNode = context.createAnalyser();
var volumeArr = [];
var recentVolume = [];

//FFTされたデータをもらう配列
var timeDomainData = new Uint8Array(analyserNode.frequencyBinCount);
var volume = document.getElementById("volume");
var sub = 0;

var pushedCharCode = "";
$(window).keydown(function(e){
   if( $( '#select1' ).is( ':checked' ) ){
        pushedCharCode =e.keyCode;
        console.log('pushedCharCode: ' + pushedCharCode)
        if (pushedCharCode == 9) // tabで キーイベント取得解除
            $( '#select1' ).attr("checked", false )
                setTimeout("checkRecent()", 50); //要調整
        return false;
    }
});
var maxVol;
var arr = [];
function checkRecent() {
    for (var j = volumeArr.length-40; j < volumeArr.length; j++) {
        recentVolume.push(volumeArr.pop());
    };
    console.log(recentVolume);
    maxVol = Math.max.apply(null,recentVolume) - 128;
    console.log("maxVol: "+maxVol);
    maxVol = maxVol * 2 + 15;
    console.log(maxVol);
    if (pushedCharCode==8) {
        $(".char:last").remove();
    }else{
        $("#volume").append("<span class='char' style='font-size:"+maxVol+"px;'>"+String.fromCharCode(pushedCharCode)+"</span>");
    }
    recentVolume = [];
}

setInterval(function(){
    var max = 0.0;
    freqData = new Uint8Array(analyserNode.frequencyBinCount);
    analyserNode.getByteFrequencyData(freqData);


    analyserNode.getByteTimeDomainData(timeDomainData);
    for (var i=0; i<timeDomainData.length; ++i){
        var d = timeDomainData[i];
        if(d > max) {
            max = d;
        }
    }
    volumeArr.push(max);
},0);

function play(){
	navigator.webkitGetUserMedia({video:false, audio:true}, function(stream) {
		var source = context.createMediaStreamSource(stream);
        source.connect(analyserNode);
    });
}
play();
