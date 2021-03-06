﻿using System;
using System.Collections;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using FluentInstallation.Web.Administration;
using Xunit;

namespace FluentInstallation.IntegrationTests
{
    public class InstallerContextTests
    {

        
        public IInstallerContext CreateSut(Hashtable parameters)
        {
            return new TestInstallerContext(parameters);
        }
        
        [Fact]
        public void CanInstallWebsiteCorrectly()
        {

            var sut = CreateSut(new Hashtable());
            
            sut
                .ConfigureWebServer()
                .RemoveWebsite("Test")
                .AddWebsite(website =>
                {
                    website.Named("Test");
                    website.OnPhysicalPath(@"C:\");

                    website.AddBinding(binding =>
                    {
                        binding.OnPort(9090);
                        binding.UseProtocol("http");
                    });

                    website.AddApplication(x => x.UseAlias("App1").OnPhysicalPath(@"C:\"));
                    website.AddApplication(x => x.UseAlias("App1/App2").OnPhysicalPath(@"C:\"));

                })  
                .Commit();

         }

        
    }




    
}