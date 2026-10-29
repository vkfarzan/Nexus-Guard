using System;
using System.IO;
using System.Security.Cryptography;
using System.Reflection;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Windows.Forms;
internal static class PortableHost {
  static byte[] Resource(string name) { using (var input = Assembly.GetExecutingAssembly().GetManifestResourceStream(name)) { if (input == null) throw new Exception("Missing application component: " + name); using (var buffer = new MemoryStream()) { input.CopyTo(buffer); return buffer.ToArray(); } } }
  static void Put(string path, byte[] content) { if (!File.Exists(path) || !Same(File.ReadAllBytes(path),content)) { string temp=path+"."+System.Diagnostics.Process.GetCurrentProcess().Id+".tmp"; File.WriteAllBytes(temp,content); if(File.Exists(path)) File.Delete(path); File.Move(temp,path); } }
  static bool Same(byte[] a,byte[] b) { if(a.Length!=b.Length)return false; for(int i=0;i<a.Length;i++)if(a[i]!=b[i])return false; return true; }
  [STAThread] static int Main(string[] args) {
    try {
      byte[] script=Resource("NexusGuard.script"),icon=Resource("NexusGuard.icon"); string version;
      using(var hash=SHA256.Create()) version=BitConverter.ToString(hash.ComputeHash(script)).Replace("-","").Substring(0,16);
      string root=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"NexusGuard","runtime",version); Directory.CreateDirectory(root);
      string scriptPath=Path.Combine(root,"Nexus-Watcher.ps1"); Put(scriptPath,script); Put(Path.Combine(root,"Nexus-Watcher.ico"),icon);
      if(args.Length>0 && args[0]=="--self-test") return File.Exists(scriptPath)?0:1;
      Environment.SetEnvironmentVariable("NEXUS_GUARD_APP_PATH",Assembly.GetExecutingAssembly().Location,EnvironmentVariableTarget.Process);
      var state=InitialSessionState.CreateDefault(); state.ExecutionPolicy=Microsoft.PowerShell.ExecutionPolicy.Bypass;
      using(var runspace=RunspaceFactory.CreateRunspace(state)) { runspace.ApartmentState=System.Threading.ApartmentState.STA; runspace.Open(); using(var ps=PowerShell.Create()) { ps.Runspace=runspace; ps.AddCommand(scriptPath); ps.Invoke(); if(ps.HadErrors) MessageBox.Show(ps.Streams.Error[0].ToString(),"Nexus Guard"); } }
      return 0;
    } catch(Exception ex) { MessageBox.Show(ex.Message,"Nexus Guard"); return 1; }
  }
}
