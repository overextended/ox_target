<<<<<<< refs/remotes/origin/main
const resource = GetParentResourceName();

export async function fetchNui(eventName, data) {
  const resp = await fetch(`https://${resource}/${eventName}`, {
=======
export async function fetchNui(eventName, data) {
  const resp = await fetch(`https://${GetParentResourceName()}/${eventName}`, {
>>>>>>> test(web): horrible vanilla js
    method: "post",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  });

  return await resp.json();
}
