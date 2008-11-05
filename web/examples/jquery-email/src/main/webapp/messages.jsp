<html>
<title>jQuery Message Demo</title>
<head>
    <link href="style.css" type="text/css" rel="stylesheet"/>
</head>
<script type="text/javascript" src="js/jquery-1.2.1.pack.js"></script>
<script type="text/javascript" src="js/jquery.dimensions.js"></script>
<script type="text/javascript" src="js/jquery.corner.min.js"></script>
<script type="text/javascript" src="js/jquery.blockUI.min.js"></script>
<script>

var isIE = 0;
if (navigator.appName.toUpperCase().match(/MICROSOFT INTERNET EXPLORER/) != null) {
    isIE = 1;
    document.writeln("<link href=\"style_ie.css\" type=\"text/css\" rel=\"stylesheet\" />");
}

$(document).ready(function() {

    view = "Inbox";
    if (window.location.href.indexOf("?view=Sent") != -1) {
        view = "Sent";
    }

    $("#content").corner("12px");

    $("#mailboxes").corner("8px");
    $("#topnavigation").corner("8px");
    $("#selectall").click(selectAll);

    if (view == "Inbox") {
        $("#inbox").addClass("mailbox_selected");
    } else {
        $("#sentBox").addClass("mailbox_selected");
    }

    var compose = $('#composeMessage');
    var deleteMess = $('#deleteMessage');
    var readMess = $('#readMessage');

    firstRow = true;

    $.get("pwr/" + view + "/messages", {userId: 1}, function(data) {
        for (var i = 0; i < data.object_array.length; i++) {

            var to = data.object_array[i].to;
            var from = data.object_array[i].from;
            var subject = data.object_array[i].subject;
            var mailDate = data.object_array[i].sentTime;

            insertRow(to, from, subject, mailDate);

        }
    }, "json");

    // For composing a message
    $("#compose").click(function() {
        $.blockUI(compose, {width:'540px', height:'300px'});
    });

    $("#cancelCompose").click(function() {
        document.composeMailForm.reset();
        $.unblockUI();
    });

    $("#submitMessage").click(function() {
        sendMessage();
        $.unblockUI();
    });

    // For deleting a message
    $("#delete").click(function() {
        $.blockUI(deleteMess, {width:'380px', height:'120px'});
    });

    $("#submitDelete").click(function() {
        deleteMessages();
        $.unblockUI();
    });

    $("#cancelDelete").click(function() {
        $.unblockUI();
    });

    // For reading/replying to a message
    var subject = document.composeMailForm.subject;
    var message = document.composeMailForm.message;
    var to = document.composeMailForm.to;

    $("#replyMessage").click(function() {
        var subj = "RE: " + document.readMessageForm.subject.value;
        var mess = "\n\n***************\n\n" + document.readMessageForm.message.value;
        var from = document.readMessageForm.from.value;
        subject.value = subj;
        message.value = mess;
        to.value = from;
        $.blockUI(compose, {width:'540px', height:'300px'});
    });

    $("#cancelRead").click(function() {
        document.readMessageForm.reset();
        $.unblockUI();
    });

    // Highlights the rows when you single click on them
    $(".messageRow").click(function() {
        $(".messageRow").removeClass("message_selected");
        $(this).addClass("message_selected");
    });

    // Opens up the message to read it when you double click on a message
    $(".messageRow").dblclick(function() {
        if ($(this).hasClass("mail_unread"))
        {
            $(this).removeClass("mail_unread");
        }
        $.post("pwr/" + view + "/read", {msgId: this.id, view: view }, function(data) {
            if (data != "ERROR")
            {
                // using JSON objects
                document.readMessageForm.subject.value = data.MessageData.subject;
                document.readMessageForm.message.value = data.MessageData.message;
                document.readMessageForm.from.value = data.MessageData.from;
            }
        }, "json");
        $.blockUI(readMess, {width:'540px', height:'300px'});
    });

});

function insertRow(to, from, subject, mailDate) {

    var newRow;

    if (firstRow == true) {
        newRow = $('#mailtable tr:last');
        firstRow = false;
    } else {
        newRow = $('#mailtable tr:last').clone();
    }

    $('td[class*=mail-to]', newRow).html(to);
    $('td[class*=mail-from]', newRow).html(from);
    $('td[class*=mail-subj]', newRow).html(subject);
    $('td[class*=mail-date]', newRow).html(mailDate);

    $('#mailtable').append(newRow);

}

function selectAll()
{
    var checked = $("#selectall").attr("checked");
    $(".selectable").each(function() {
        var subChecked = $(this).attr("checked");
        if (subChecked != checked)
            $(this).click();
    });
}

function deleteMessages()
{
    $(".selectable:checked").each(function() {
        $("#" + $(this).val()).remove();
        $.post("pwr/" + view + "/delete", {delId: $(this).val()});
    });
}

function sendMessage() {

    var subject = document.composeMailForm.subject.value;
    var message = document.composeMailForm.message.value;
    var to = document.composeMailForm.to.value;

    $.post("pwr/Sent/send", {subject: subject, message: message, to: to},
    function(data) {

        if (data.MessageData != undefined)
        {
            document.composeMailForm.reset();
            insertRow(to, data.MessageData.from, subject, data.MessageData.mailDate);
        }
    }, "json");
}


</script>
<body>

<center>

    <div id=content>
        <!-- start page specific -->

        <img src="images/messages.gif" style="position:absolute;left:10px;top:4px;">

        <h1>Mail</h1>
        <hr class=content_divider>

        <div style="position:relative;">

            <div id=mailboxes>
                <p><span id=inbox><a href="messages.jsp?view=Inbox">Inbox</a></span>

                <p><span id=sentBox><a href="messages.jsp?view=Sent">Sent</a></span>
            </div>


            <div id=topnavigation style="width:690px;">
                <input type=button class=iButton id=compose value="Compose">
                <input type=button class=iButton id=delete value="Delete">
            </div>

            <form name="mailForm" id="mailForm">

                <p>
                <table id=mailtable cellpadding=0 cellspacing=0>
                    <thead>
                        <tr class=header>
                            <th width=5%><input type=checkbox id=selectall></th>
                            <th width=15%>To</th>
                            <th width=20%>From</th>
                            <th width=40%>Subject</th>
                            <th width=20%>Sent</th>
                        </tr>
                    </thead>

                    <tbody>

                        <tr class="mail_unread messageRow" id="1">
                            <td class="mail"><input disabled type=checkbox name="delId" value="1"
                                                    class=selectable></td>
                            <td class="mail mail-to">TO
                            </td>
                            <td class="mail mail-from">FROM
                            </td>
                            <td class="mail mail-subj">SUBJECT
                            </td>
                            <td class="mail mail-date">DATE-TIME
                            </td>
                        </tr>

                    </tbody>
                </table>

            </form>
            <script>
                if (isIE)
                {
                    document.writeln("<p><br><br><br><br><br><br><br><br><br>");
                }
            </script>
        </div>

        <!-- end page specific -->
    </div>
</center>

<div id=composeMessage style="display:none;cursor:default;">
    <p>

    <h2>Compose Mail</h2>

    <form name="composeMailForm" id="composeMailForm">
        <table width=100% class="content_table">
            <tr>
                <td class=right>To</td>
                <td class=left_offset><input class="textfield" type=text name=to id=to> <span class=error_message
                                                                                              id=subject_error></span>
                </td>
            </tr>
            <tr>
                <td class=right>Subject</td>
                <td class=left_offset><input class="textfield" type=text name=subject id=subject> <span
                        class=error_message id=subject_error></span></td>
            </tr>
            <tr>
                <td class=right>Message</td>
                <td class=left_offset><textarea class="textfield" name=message id=message
                                                style="height:120px;width:400px;"></textarea> <span class=error_message
                                                                                                    id=message_error></span>
                </td>
            </tr>
        </table>
        <p><input class=iButton type=button id=submitMessage value="Send"> <input class=iButton type=button
                                                                                  id=cancelCompose value="Cancel">
    </form>
</div>

<div id=readMessage style="display:none;cursor:default;">
    <p>

    <h2>Read Message</h2>

    <form id=readMessageForm name=readMessageForm>
        <table width=100% class="content_table">
            <tr>
                <td class=right>From</td>
                <td class=left_offset><input class="textfield" type=text id=from name=from></td>
            </tr>
            <tr>
                <td class=right>Subject</td>
                <td class=left_offset><input class="textfield" type=text id=subject name=subject></td>
            </tr>
            <tr>
                <td class=right>Message</td>
                <td class=left_offset><textarea name=message id=message class="textfield"
                                                style="height:120px;width:400px;"></textarea></td>
            </tr>
        </table>
        <p>
            <input class=iButton type=button id=replyMessage value="Reply">
            <input class=iButton type=button id=cancelRead value="Cancel">
    </form>
</div>

<div id=deleteMessage style="display:none;cursor:default;">
    <p>

    <h2>Delete Message</h2>

    <p><span id=deleteConfirm>Are you sure you want to delete this message?</span>

    <p><input class=iButton type=button id=submitDelete value="Yes"> <input class=iButton type=button id=cancelDelete
                                                                            value="No">
</div>


</body>
</html>