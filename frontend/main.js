const lambdaUrl = 'https://tb4v2suffpuo45skvqwx4d4w340rbgyq.lambda-url.us-east-1.on.aws/';

// Function to update the visitor count in the HTML
function updateVisitorCount(count) {
    const visitorsElement = document.getElementById('visitors');
    if (visitorsElement) {
        visitorsElement.textContent = count;
    }
}

// Use the fetch function to make a GET request to your Lambda function
fetch(lambdaUrl)
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    return response.text();
  })
  .then(visitorCount => {
    updateVisitorCount(visitorCount);
  })
  .catch(error => {

    console.error('Error fetching data from Lambda function:', error);
  });