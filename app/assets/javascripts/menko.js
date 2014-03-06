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
    pushedCharCode = e.keyCode;
    if( $( '#select1' ).is( ':checked' ) ){
        setTimeout("checkRecent()", 50); //要調整
        return false;
    }
});
var maxVol;
var messageArr = [];
function checkRecent() {
    for (var j = volumeArr.length-40; j < volumeArr.length; j++) {
        recentVolume.push(volumeArr.pop());
    };
    console.log(recentVolume);
    maxVol = Math.max.apply(null,recentVolume) - 128;
    console.log("maxVol: "+maxVol);
    maxVol = maxVol * 2 + 15;
    console.log(maxVol);
    if (pushedCharCode == 8) { // delete
        $('.char:last').remove();
        messageArr.pop()
    }else if (pushedCharCode == 13){ // enter
        window.chatController.sendMessage()
        $('#volume').empty()
        messageArr = []
    }else if (pushedCharCode == 9){ // tabで キーイベント取得解除
        $( '#select1' ).attr("checked", false )
    }else{
        $("#volume").append("<span class='char' style='font-size:"+maxVol+"px; line-height: "+maxVol+"px;'>"+String.fromCharCode(pushedCharCode)+"</span>");
        messageArr.push({ keyCode: pushedCharCode, vol: maxVol})
    }
    console.log('pushedCharCode: ' + pushedCharCode)
    recentVolume = [];
}

setInterval(function(){
    var max = 0.0;
    // freqData = new Uint8Array(analyserNode.frequencyBinCount);
    // analyserNode.getByteFrequencyData(freqData);

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
		source = context.createMediaStreamSource(stream);
        source.connect(analyserNode);
    });
}
play();
