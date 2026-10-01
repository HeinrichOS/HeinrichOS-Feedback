using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

[assembly: AssemblyTitle("HeinrichOS")]
[assembly: AssemblyDescription("HeinrichOS KCD2 Offline Companion")]
[assembly: AssemblyCompany("HeinrichOS")]
[assembly: AssemblyProduct("HeinrichOS Players Edition")]
[assembly: AssemblyCopyright("HeinrichOS Fan Project")]
[assembly: AssemblyVersion("1.6.0.0")]
[assembly: AssemblyFileVersion("1.6.0.0")]
[assembly: AssemblyInformationalVersion("1.6 FINAL")]

namespace HeinrichOSLauncher
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }

    public class MainForm : Form
    {
        private readonly string Root;
        private readonly string SystemRoot;
        private readonly Label StatusLabel;

        public MainForm()
        {
            Root = Application.StartupPath;
            SystemRoot = Path.Combine(Root, "HOS_SYSTEM");

            Text = "HeinrichOS KCD2";
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            ClientSize = new Size(820, 520);
            BackColor = Color.FromArgb(31, 20, 14);
            ForeColor = Color.FromArgb(239, 211, 147);

            string ico = Path.Combine(SystemRoot, "LAUNCHER", "heinrichos.ico");
            string crestPng = Path.Combine(SystemRoot, "LAUNCHER", "heinrichos.png");
            if (File.Exists(ico))
            {
                try { Icon = new Icon(ico); } catch { }
            }

            Panel top = new Panel();
            top.Dock = DockStyle.Top;
            top.Height = 135;
            top.BackColor = Color.FromArgb(52, 31, 18);
            Controls.Add(top);

            PictureBox crest = new PictureBox();
            crest.Location = new Point(38, 22);
            crest.Size = new Size(84, 84);
            crest.SizeMode = PictureBoxSizeMode.Zoom;
            try
            {
                if (File.Exists(crestPng))
                {
                    using (Image src = Image.FromFile(crestPng))
                    {
                        crest.Image = new Bitmap(src, new Size(84, 84));
                    }
                }
            }
            catch { }
            top.Controls.Add(crest);

            Label title = new Label();
            title.AutoSize = false;
            title.Location = new Point(145, 25);
            title.Size = new Size(620, 48);
            title.Font = new Font("Georgia", 25F, FontStyle.Bold);
            title.ForeColor = Color.FromArgb(246, 221, 158);
            title.Text = "HEINRICHOS";
            top.Controls.Add(title);

            Label version = new Label();
            version.AutoSize = false;
            version.Location = new Point(149, 76);
            version.Size = new Size(600, 30);
            version.Font = new Font("Georgia", 13F, FontStyle.Bold);
            version.ForeColor = Color.FromArgb(198, 155, 84);
            version.Text = "PLAYER EDITION  •  " + ReadVersion();
            top.Controls.Add(version);

            Button start = MakeButton("HeinrichOS starten", 55, 175, "start");
            start.Click += delegate { OpenShell(Path.Combine(SystemRoot, "APP", "PLAYER_V1_6", "app", "01_HTML", "index.html"), "HeinrichOS konnte nicht gestartet werden."); };
            Controls.Add(start);

            Button update = MakeButton("Update", 420, 175, "update");
            update.Click += delegate { MessageBox.Show("Der öffentliche Updatekanal ist in dieser Ausgabe noch nicht aktiviert.", "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Information); };
            Controls.Add(update);

            Button guide = MakeButton("Anleitung", 55, 320, "anleitung");
            guide.Click += delegate { OpenShell(Path.Combine(SystemRoot, "DOKUMENTATION", "README_PUBLIC.html"), "Die Public-Anleitung wurde nicht gefunden."); };
            Controls.Add(guide);

            Button feedback = MakeButton("Feedback", 420, 320, "feedback");
            feedback.Click += delegate { OpenFeedback(); };
            Controls.Add(feedback);

            StatusLabel = new Label();
            StatusLabel.AutoSize = false;
            StatusLabel.Location = new Point(55, 475);
            StatusLabel.Size = new Size(710, 24);
            StatusLabel.TextAlign = ContentAlignment.MiddleCenter;
            StatusLabel.Font = new Font("Segoe UI", 9F, FontStyle.Regular);
            StatusLabel.ForeColor = Color.FromArgb(166, 139, 103);
            StatusLabel.Text = "Offline-App • Internet nur nach bewusstem Öffnen externer Quellen";
            Controls.Add(StatusLabel);
        }

        private string ReadVersion()
        {
            string p = Path.Combine(SystemRoot, "STATE", "player_version.txt");
            try
            {
                if (File.Exists(p))
                {
                    string v = File.ReadAllText(p, Encoding.UTF8).Trim();
                    if (v.Length > 0 && v.Length < 40) return v;
                }
            }
            catch { }
            return "Version unbekannt";
        }

        private Button MakeButton(string text, int x, int y, string iconKey)
        {
            Button b = new Button();
            b.Location = new Point(x, y);
            b.Size = new Size(345, 118);
            b.Text = text;
            b.Font = new Font("Georgia", 15F, FontStyle.Bold);
            b.ForeColor = Color.FromArgb(246, 221, 158);
            b.BackColor = Color.FromArgb(70, 39, 21);
            b.FlatStyle = FlatStyle.Flat;
            b.FlatAppearance.BorderColor = Color.FromArgb(151, 100, 48);
            b.FlatAppearance.BorderSize = 2;
            b.TextImageRelation = TextImageRelation.ImageBeforeText;
            b.ImageAlign = ContentAlignment.MiddleLeft;
            b.TextAlign = ContentAlignment.MiddleCenter;
            b.Padding = new Padding(26, 8, 20, 8);
            Image img = LoadButtonImage(iconKey);
            if (img != null) b.Image = img;
            return b;
        }

        private Image LoadButtonImage(string key)
        {
            try
            {
                if (key == "start")
                {
                    string p = Path.Combine(SystemRoot, "LAUNCHER", "heinrichos.png");
                    if (!File.Exists(p)) return null;
                    using (Image src = Image.FromFile(p))
                    {
                        return new Bitmap(src, new Size(64, 64));
                    }
                }
                string file = key == "update" ? "update.png" : key == "anleitung" ? "anleitung.png" : "feedback.png";
                string path = Path.Combine(SystemRoot, "LAUNCHER", "icons", file);
                if (!File.Exists(path)) return null;
                using (Image src = Image.FromFile(path))
                {
                    return new Bitmap(src, new Size(64, 64));
                }
            }
            catch { return null; }
        }

        private void OpenShell(string path, string errorText)
        {
            try
            {
                if (!File.Exists(path))
                {
                    MessageBox.Show(errorText + "\n\n" + path, "HeinrichOS", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                ProcessStartInfo psi = new ProcessStartInfo(path);
                psi.UseShellExecute = true;
                Process.Start(psi);
            }
            catch (Exception ex)
            {
                MessageBox.Show(errorText + "\n\n" + ex.Message, "HeinrichOS", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void RunUpdateCenter()
        {
            string ucRoot = Path.Combine(SystemRoot, "UPDATE_CENTER");
            string engine = Path.Combine(ucRoot, "ENGINE", "updater.ps1");
            string packageRoot = Path.Combine(ucRoot, "PACKAGE", "AVAILABLE");
            string notesPath = Path.Combine(packageRoot, "release_notes.txt");

            if (!File.Exists(engine) || !Directory.Exists(packageRoot))
            {
                MessageBox.Show(
                    "Der HeinrichOS-Updatekanal ist momentan nicht verfügbar.\n\nEs wurde nichts verändert.",
                    "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            try
            {
                StatusLabel.Text = "Update wird geprüft ...";
                Cursor = Cursors.WaitCursor;
                Application.DoEvents();

                int checkCode = RunUpdateEngine(engine, packageRoot, false);
                Cursor = Cursors.Default;

                if (checkCode == 10)
                {
                    StatusLabel.Text = "HeinrichOS ist auf dem neuesten Stand.";
                    MessageBox.Show(
                        "HeinrichOS ist bereits auf dem neuesten verfügbaren Stand.",
                        "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                if (checkCode != 0)
                {
                    StatusLabel.Text = "Updateprüfung beendet.";
                    ShowUpdateFailure(checkCode);
                    return;
                }

                string notes = File.Exists(notesPath)
                    ? File.ReadAllText(notesPath, Encoding.UTF8).Trim()
                    : "Ein neues HeinrichOS-Update ist verfügbar.";

                DialogResult answer = MessageBox.Show(
                    notes + "\n\nJetzt installieren?",
                    "HeinrichOS Update verfügbar",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question);

                if (answer != DialogResult.Yes)
                {
                    StatusLabel.Text = "Update wurde nicht installiert.";
                    return;
                }

                StatusLabel.Text = "Update wird sicher installiert ...";
                Cursor = Cursors.WaitCursor;
                Application.DoEvents();

                int applyCode = RunUpdateEngine(engine, packageRoot, true);
                Cursor = Cursors.Default;

                if (applyCode == 0)
                {
                    StatusLabel.Text = "Update erfolgreich.";
                    MessageBox.Show(
                        "Update erfolgreich.\n\nHeinrichOS ist jetzt auf dem neuesten Stand.",
                        "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                StatusLabel.Text = "Update konnte nicht abgeschlossen werden.";
                ShowUpdateFailure(applyCode);
            }
            catch (Exception ex)
            {
                Cursor = Cursors.Default;
                StatusLabel.Text = "Updateprüfung beendet.";
                MessageBox.Show(
                    "Der Updatevorgang konnte nicht gestartet werden.\n\nEs wurde nichts verändert. HeinrichOS bleibt nutzbar.\n\n" + ex.Message,
                    "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            finally
            {
                Cursor = Cursors.Default;
            }
        }

        private int RunUpdateEngine(string engine, string packageRoot, bool apply)
        {
            // Public Players V1.6: öffentlicher Update-Transport ist bewusst deaktiviert.
            // Kein PowerShell- oder Hintergrundprozess wird gestartet.
            return 10;
        }


        private void ShowUpdateFailure(int code)
        {
            if (code == 31)
            {
                MessageBox.Show(
                    "Update konnte nicht abgeschlossen werden.\n\nDer bisherige Stand wurde automatisch vollständig wiederhergestellt. HeinrichOS ist weiterhin nutzbar.\n\nTechnische Details wurden im Hintergrund protokolliert.",
                    "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (code == 32)
            {
                MessageBox.Show(
                    "Update konnte nicht abgeschlossen werden und die automatische Wiederherstellung konnte nicht vollständig bestätigt werden.\n\nBitte HeinrichOS vorerst nicht weiter aktualisieren. Die technischen Details wurden protokolliert.",
                    "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            string message = "Das Update konnte nicht sicher vorbereitet werden.\n\nEs wurden keine Produktdateien verändert. HeinrichOS bleibt nutzbar.";
            if (code == 22) message = "Die Sicherheitsprüfung des vorhandenen HeinrichOS-Stands ist fehlgeschlagen.\n\nEs wurde nichts verändert. HeinrichOS bleibt nutzbar.";
            if (code == 23) message = "Dieses Update passt nicht eindeutig zum vorhandenen HeinrichOS-Stand.\n\nEs wurde nichts verändert. HeinrichOS bleibt nutzbar.";
            if (code == 24) message = "Das Updatepaket konnte nicht vollständig geprüft werden.\n\nEs wurde nichts verändert. HeinrichOS bleibt nutzbar.";

            MessageBox.Show(
                message + "\n\nTechnische Details wurden im Hintergrund protokolliert.",
                "HeinrichOS Update", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private void OpenFeedback()
        {
            const string url = "https://github.com/HeinrichOS/HeinrichOS-Feedback/issues/new/choose";
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo(url);
                psi.UseShellExecute = true;
                Process.Start(psi);
                StatusLabel.Text = "Feedback-Seite im Browser geöffnet • keine automatische Datenübertragung";
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Die HeinrichOS-Feedbackseite konnte nicht geöffnet werden.\n\nEs wurden keine Daten übertragen.\n\n" + ex.Message,
                    "HeinrichOS Feedback", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private string Tail(string text)
        {
            if (String.IsNullOrEmpty(text)) return "";
            text = text.Trim();
            if (text.Length <= 1000) return text;
            return "..." + text.Substring(text.Length - 1000);
        }
    }
}