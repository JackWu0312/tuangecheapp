package cn.com.tuangeche.api.flutter_tuangeche;

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import com.tendcloud.tenddata.TCAgent;
class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        TCAgent.init(getApplicationContext(), "31BB4D12E12848B6B55889BA9D4CB6F6", "firim1111");
    }
}