import tkinter as tk
from gui import PetAdoptionApp


# ============== RUN APP ==============
if __name__ == "__main__":
    root = tk.Tk()
    app = PetAdoptionApp(root)
    root.mainloop()