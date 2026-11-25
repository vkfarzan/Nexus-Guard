using System;
using System.IO;
using System.Security.Cryptography;
using System.Reflection;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Windows.Forms;
using System.Diagnostics;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Runtime.InteropServices;
internal static class PortableHost {
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] static extern IntPtr OpenSCManager(string machine, string database, uint access);
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)] static extern IntPtr OpenService(IntPtr manager, string name, uint access);
  [DllImport("advapi32.dll")] static extern bool CloseServiceHandle(IntPtr handle);
  static bool CanControlService() {
    IntPtr manager=OpenSCManager(null,null,1); if(manager==IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
    try { IntPtr service=OpenService(manager,"NexusService",0x34); if(service!=IntPtr.Zero) { CloseServiceHandle(service); return true; } int error=Marshal.GetLastWin32Error(); if(error==1060) return true; if(error==5) return false; throw new System.ComponentModel.Win32Exception(error); }
    finally { CloseServiceHandle(manager); }
  }
  static string Sc(string arguments) {
    var info=new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"sc.exe"),arguments) { UseShellExecute=false, CreateNoWindow=true, RedirectStandardOutput=true, RedirectStandardError=true };
    using(var p=Process.Start(info)) { string output=p.StandardOutput.ReadToEnd(); string errors=p.StandardError.ReadToEnd(); p.WaitForExit(); if(p.ExitCode!=0) throw new Exception("Service configuration failed: "+errors+" "+output); return output.Trim(); }
  }
  static void GrantServiceAccess(string sidText) {
    var sid=new SecurityIdentifier(sidText);
    var descriptor=new RawSecurityDescriptor(Sc("sdshow NexusService"));
    var acl=descriptor.DiscretionaryAcl; if(acl==null) throw new Exception("Nexus service has no access control list.");
    int index=0; while(index<acl.Count && (acl[index].AceFlags & AceFlags.Inherited)==0) index++;
    acl.InsertAce(index,new CommonAce(AceFlags.None,AceQualifier.AccessAllowed,0x34,sid,false,null));
    Sc("sdset NexusService "+descriptor.GetSddlForm(AccessControlSections.All));
  }
  static byte[] Resource(string name) { using (var input = Assembly.GetExecutingAssembly().GetManifestResourceStream(name)) { if (input == null) throw new Exception("Missing application component: " + name); using (var buffer = new MemoryStream()) { input.CopyTo(buffer); return buffer.ToArray(); } } }
  static void Put(string path, byte[] content) { if (!File.Exists(path) || !Same(File.ReadAllBytes(path),content)) { string temp=path+"."+System.Diagnostics.Process.GetCurrentProcess().Id+".tmp"; File.WriteAllBytes(temp,content); if(File.Exists(path)) File.Delete(path); File.Move(temp,path); } }
  static bool Same(byte[] a,byte[] b) { if(a.Length!=b.Length)return false; for(int i=0;i<a.Length;i++)if(a[i]!=b[i])return false; return true; }
  [STAThread] static int Main(string[] args) {
    try {
      if(args.Length==2 && args[0]=="--grant-service") { GrantServiceAccess(args[1]); return 0; }
      if(!(args.Length>0 && args[0]=="--self-test") && !CanControlService()) {
        var prompt=MessageBox.Show("Nexus Guard needs permission to start and stop the Nexus service. Windows will ask for administrator approval once. Continue?","Nexus Guard",MessageBoxButtons.OKCancel,MessageBoxIcon.Information);
        if(prompt!=DialogResult.OK) return 1;
        var info=new ProcessStartInfo(Assembly.GetExecutingAssembly().Location,"--grant-service "+WindowsIdentity.GetCurrent().User.Value) { UseShellExecute=true, Verb="runas" };
        using(var elevated=Process.Start(info)) { if(elevated==null) return 1; elevated.WaitForExit(); if(elevated.ExitCode!=0 || !CanControlService()) throw new Exception("Permission to control the Nexus service was not granted."); }
      }
      byte[] script=Resource("NexusGuard.script"),icon=Resource("NexusGuard.icon"); string version;
      using(var hash=SHA256.Create()) version=BitConverter.ToString(hash.ComputeHash(script)).Replace("-","").Substring(0,16);
      string root=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"NexusGuard","runtime",version); Directory.CreateDirectory(root);
      string scriptPath=Path.Combine(root,"Nexus-Watcher.ps1"); Put(scriptPath,script); Put(Path.Combine(root,"Nexus-Watcher.ico"),icon);
      if(args.Length>0 && args[0]=="--self-test") return File.Exists(scriptPath)?0:1;
      Environment.SetEnvironmentVariable("NEXUS_GUARD_APP_PATH",Assembly.GetExecutingAssembly().Location,EnvironmentVariableTarget.Process);
      var state=InitialSessionState.CreateDefault(); state.ExecutionPolicy=Microsoft.PowerShell.ExecutionPolicy.Bypass;
      using(var runspace=RunspaceFactory.CreateRunspace(state)) { runspace.ApartmentState=System.Threading.ApartmentState.STA; runspace.Open(); using(var ps=PowerShell.Create()) { ps.Runspace=runspace; ps.AddCommand(scriptPath); ps.Invoke(); if(ps.HadErrors && ps.Streams.Error.Count > 0) MessageBox.Show(ps.Streams.Error[0].ToString(),"Nexus Guard"); } }
      return 0;
    } catch(Exception ex) { MessageBox.Show(ex.Message,"Nexus Guard"); return 1; }
  }
}
