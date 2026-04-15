
// import { useDarkMode } from '../../context/DarkModeContext';

import Papa from "papaparse";

interface FileModalProps {
    data: any[];
    setData: (file: any) => void;
}

export function FileModal({ data, setData }: FileModalProps) {
    // const { isDarkMode } = useDarkMode();

    const readCSVFile = (file: File): Promise<any[]> => {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
    
            reader.onload = (event) => {
                if (!event.target?.result) {
                    reject(new Error("File reading failed"));
                    return;
                }
    
                // Parse CSV from file content
                Papa.parse(event.target.result as string, {
                    header: true, // Parses first row as object keys
                    skipEmptyLines: true,
                    complete: (result) => resolve(result.data),
                    error: (error:any) => reject(error),
                });
            };
    
            reader.onerror = () => reject(new Error("File reading error"));
            reader.readAsText(file); // Read file as text
        });
    };

    const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];

        if (!file) return;
        if (!file.name.endsWith(".csv")) {
            console.error("Invalid file type! Please upload a CSV file.");
            return;
        }
    
        try {
            const result = await readCSVFile(file);
            setData(result);
            console.log("Parsed CSV Data:", result);
        } catch (error) {
            console.error("Error reading CSV:", error);
        }
    };

    // alert(data.length)

    if (data.length !=0) return;


    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-gray-200 bg-opacity-75">
            <div className={`${false ? 'bg-gray-800' : 'bg-white'} rounded-xl p-8 w-full max-w-md transition-colors`}>
                <h2 className={`text-2xl font-bold mb-6 ${false ? 'text-white' : 'text-gray-900'}`}>
                    Please Select a File to view
                </h2>
                <input onChange={handleFileUpload} type="file" id="fileInput" accept=".csv" />
            </div>
        </div>
    );
}
